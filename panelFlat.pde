
public class panelFlat
{
  ArrayList poly; // list of points that make the panel poly
  
  // convenience: the four points
  Vec2D pointBottomLeft; // LET OP: omgekeerd van scherm
  Vec2D pointBottomRight;
  Vec2D pointTopLeft;
  Vec2D pointTopRight;
  
  Line2D origLineLeft = null;
  Line2D origLineRight = null;
  
  public zzModel model;
  
  public String type; // TO DO
  public String name;
  public float panelScale = 1.0;
  public boolean mirrored = false; 
  public Vec2D position; // Position on canvas
  public float panelWidth;
  public float panelHeight; // after possible scale
  public int panelWidthOrig;
  public int panelHeightOrig;
  public int panelHeightOrigOffsetBottom;
  public int panelHeightOrigOffsetTop;
  public float cuttingAngleTop;
  public float cuttingAngleBottom;
  
  ArrayList extendedLines = new ArrayList();
  
  public panelFlat(ArrayList polypoints, String n, float a, float b, zzModel p)
  {
      poly = polypoints;
      name = n;
      cuttingAngleTop = a;
      cuttingAngleBottom = b;
      // individual points:
      setPoints(); // from poly
      
      model = p;
      
      // default position: 0,0
      position = new Vec2D(0,0);
      

       
       // width and height
      Line2D l1 = new Line2D (pointBottomLeft, pointTopLeft);
      Line2D l2 = new Line2D (pointBottomRight, pointTopRight);
      
      panelHeight = l1.getLength();
      if(l2.getLength() > panelHeight){
         panelHeight = l2.getLength();
       }
         
      panelHeightOrig = round(panelHeight * 10); // in mm
      panelHeightOrigOffsetBottom = round((pointBottomRight.y - pointBottomLeft.y) * 10.0 / panelScale);
      panelHeightOrigOffsetTop = round((pointTopRight.y - pointTopLeft.y) * 10.0 / panelScale);
      
      l1.a = l1.a.sub(l1.getDirection().scale(l1.getLength()));

      //panelWidth = (l1.closestPointTo(pointBottomRight).distanceTo(pointBottomRight));
      panelWidth = pointBottomRight.x - pointBottomLeft.x;
      panelWidthOrig = round(panelWidth * 10);
      
      // TYPE  // WALL_OUT WALL_IN ROOF_IN ROOF_OUT
      if(abs(pointBottomLeft.y - pointBottomRight.y) < 0.1)
      {
        // wall
        if(pointTopRight.y - pointTopLeft.y < 0)
        {
          this.type = "WALL_IN";
        }
         else { 
           this.type = "WALL_OUT";}
      }
      else 
      {
         // ROOF
         this.type = "ROOF" ; // TODO  
      }
  }
  
  public float heightDiff()
  { 
    return abs(pointTopRight.y - pointTopLeft.y);
  }
  
  public float getConstructionTaperAngleRight()
  {  
      // DIT MOET BETER => PARENT CHAIN
      //float a = atan(abs(zzHouse.L2_y[1] - zzHouse.L2_y[0]) / abs(zzHouse.L_x[1] - zzHouse.L_x[0]));
      //println("ANGLE" + a * 180/PI);
      //return a;
      return 0.0; // TODO
  }  
  
  public void drawAt(float x, float y, PGraphics canvas)
  {
      boolean DRAW_DXF = false;
        
      if(canvas.getClass().toString().equals("class processing.dxf.RawDXF"))
         DRAW_DXF = true;
    
      // save position
      position = new Vec2D(x,y);
    
      canvas.pushStyle();
      canvas.stroke(0xFF000000);
      canvas.noFill();
      canvas.beginShape();
      
      // DRAW POLY
      for(int c = 0; c < poly.size(); c++)
      {
          Vec2D p = (Vec2D) poly.get(c);
          
          canvas.vertex(p.x + position.x, p.y + position.y);
      }
      
      canvas.endShape(CLOSE); // END POLY
      
      // DRAW EXTENDED LINES
      canvas.strokeWeight(0.5);
      canvas.stroke(0xFF333333);
      
      for(int c = 0; c < extendedLines.size(); c++)
      {
          Line2D l = (Line2D) extendedLines.get(c);
          
          //canvas.line(l.a.x + position.x, l.a.y + position.y, l.b.x + position.x, l.b.y + position.y);
          dashline(l.a.x + position.x, l.a.y + position.y, l.b.x + position.x, l.b.y + position.y, 2.0, 2.0, canvas);
      }
      
     
       // description
      canvas.fill(0xFF000000);
      canvas.pushMatrix();
      canvas.translate(pointBottomLeft.x + panelWidth/2 + position.x, pointBottomLeft.y + panelHeight/2 + position.y);
      //println(pointBottomLeft.y + "/" + panelHeight + "/" + position.y); 
      canvas.rotate(PI/2);
      
      if(!DRAW_DXF)
      {
        // can't draw on DXF file
        canvas.textSize(7);
        canvas.text(name, -20 , -5 );
        canvas.textSize(5);
        
        canvas.text("cut: " + cuttingAngleBottom + " / " + cuttingAngleTop , -20 , 0 );
        // SAW DIMS
        canvas.textSize(3);
        canvas.text("[w=" + panelWidthOrig + "|h=" + panelHeightOrig + "\nhoff_1=" + panelHeightOrigOffsetBottom + "|hoff_2=" + panelHeightOrigOffsetTop + "]" , -20 , 5 ); 
      }
      canvas.popMatrix();
      canvas.noFill();
     
      
      canvas.popStyle();
      
  }
  
  public Vec2D getFirstPoint()
  {
     return (Vec2D) poly.get(0); 
  }
  
  public void extend(float offset)
  {
     // EXTENDS POLY TO RIGHT
     
     // save old line
     extendedLines.add(new Line2D(pointBottomRight, pointTopRight));
     
     Vec2D sideTopVector = pointTopRight.sub(pointTopLeft);
     Vec2D sideBottomVector = pointBottomRight.sub(pointBottomLeft);

     float sideTopLength = sideTopVector.magnitude();
     float sideBottomLength = sideBottomVector.magnitude();
  
     // replace old coordinates
     pointTopRight = pointTopRight.add(sideTopVector.normalize().scale(sideTopLength / panelWidth * offset));
     pointBottomRight = pointBottomRight.add(sideBottomVector.normalize().scale(sideBottomLength / panelWidth * offset));
     
     poly.set(1, pointBottomRight);
     poly.set(2, pointTopRight);
     
     // update width / height
     panelWidth += offset;    
     
     // UPDATE POINTS
     setPoints();
     
  }
  
  public void shorten(float offset)
  {
     // SHORTENS POLY TO LEFT
     
     // save old line
     extendedLines.add(new Line2D(pointBottomLeft, pointTopLeft));
     
     Vec2D sideTopVector = pointTopLeft.sub(pointTopRight);
     Vec2D sideBottomVector = pointBottomLeft.sub(pointBottomRight);

     float sideTopLength = sideTopVector.magnitude();
     float sideBottomLength = sideBottomVector.magnitude();
  
     // replace old coordinates
     pointTopLeft = pointTopLeft.sub(sideTopVector.normalize().scale(sideTopLength / panelWidth * offset));
     pointBottomLeft = pointBottomLeft.sub(sideBottomVector.normalize().scale(sideBottomLength / panelWidth * offset));
     
     poly.set(0, pointBottomLeft);
     poly.set(3, pointTopLeft);
     
     // update width / height
     panelWidth -= offset;    
     
     // UPDATE POINTS
     setPoints();
     
  }
  public void panelScale(float s)
  {
      //println("TOPLEFT:" + pointTopLeft.x);
      //println("BOTTOMLEFT X:" + pointBottomLeft.x);
      //println("BOTTOMLEFT Y:" + pointBottomLeft.y);
      
      panelScale = s;
      
      for(int c = 0; c < poly.size(); c++)
      {
         Vec2D pnt = (Vec2D) poly.get(c);
         
         // SCALE
         // let op: alignment
         pnt.x *= s;
         pnt.y *= s;
      }
      
      //
      
      panelWidth = pointBottomRight.x - pointBottomLeft.x;
      panelHeight = abs(pointBottomRight.y - pointTopRight.y);
      //println("H1 " + panelHeight);
      
      if(panelHeight < abs(pointBottomLeft.y - pointTopLeft.y))
      {
         // other side is longer 
         panelHeight = abs(pointBottomLeft.y - pointTopLeft.y);
      }
      
      // scale extented lines
      for(int c = 0; c < extendedLines.size(); c++)
      {
         Line2D l = (Line2D) extendedLines.get(c);
         
         // SCALE
         // let op: alignment
         l.a.x *= s;
         l.a.y *= s;
         
         l.b.x *= s;
         l.b.y *= s;
      }
      
      // UPDATE POINTS
      setPoints();
      
  }
  public void mirror()
  {
      mirrored = true;
    
      // get mid y
      float midY = panelHeight / 2.0;
      // copy poly arraylist
      ArrayList tmpPoly = (ArrayList) poly.clone();
      
      for(int c = 0; c < tmpPoly.size(); c++)
      {
          // mirror points
          Vec2D pnt_old = (Vec2D) tmpPoly.get(c);
          // LET OP: geldt voor alignde polys
          poly.set(3 - c, new Vec2D(pnt_old.x, midY - pnt_old.y + midY));
      }
      
      
      // SWAP CUTTINGANGLES
      float tmp = cuttingAngleTop;
      cuttingAngleTop = cuttingAngleBottom;
      cuttingAngleBottom = tmp;
      
      // MIRROR EXTENDED LINES
       for(int c = 0; c < extendedLines.size(); c++)
      {
         Line2D l = (Line2D) extendedLines.get(c);
         
         l.a.y = midY - l.a.y + midY;
         l.b.y = midY - l.b.y + midY;
      }
      
      // UPDATE POINTS
      setPoints();
      
  }
  
  public void alignToPanel(panelFlat prevPanel)
  {
      // align to the side of previous panel 
      if(prevPanel != null)
      {
        //println("ALIGN PANEL");
        //println(prevPanel.position); 
        
        Vec2D prevFlatPanelalignVector = pointBottomLeft.sub(prevPanel.pointBottomRight);// ORIENTATION: left => left // bottom => top
        //position = position.add(prevFlatPanelalignVector.add(prevPanel.position));
        
      }
  }
  
  public void setPoints()
  {
       // set individual points from poly 
       pointBottomLeft = (Vec2D) poly.get(0);
       pointBottomRight = (Vec2D) poly.get(1);
       pointTopLeft = (Vec2D) poly.get(3);
       pointTopRight = (Vec2D) poly.get(2);
      
      // update other stats
      panelHeightOrigOffsetBottom = abs(round((pointBottomRight.y - pointBottomLeft.y)*10 / panelScale));
      panelHeightOrigOffsetTop = abs(round((pointTopRight.y - pointTopLeft.y)*10 / panelScale));
  }
  
    /*
   * Draw a dashed line with given set of dashes and gap lengths.
   * x0 starting x-coordinate of line.
   * y0 starting y-coordinate of line.
   * x1 ending x-coordinate of line.
   * y1 ending y-coordinate of line.
   * spacing array giving lengths of dashes and gaps in pixels;
   *  an array with values {5, 3, 9, 4} will draw a line with a
   *  5-pixel dash, 3-pixel gap, 9-pixel dash, and 4-pixel gap.
   *  if the array has an odd number of entries, the values are
   *  recycled, so an array of {5, 3, 2} will draw a line with a
   *  5-pixel dash, 3-pixel gap, 2-pixel dash, 5-pixel gap,
   *  3-pixel dash, and 2-pixel gap, then repeat.
   */
  public void dashline(float x0, float y0, float x1, float y1, float[ ] spacing, PGraphics canvas)
  {
    float distance = dist(x0, y0, x1, y1);
    float [ ] xSpacing = new float[spacing.length];
    float [ ] ySpacing = new float[spacing.length];
    float drawn = 0.0;  // amount of distance drawn
   
    if (distance > 0)
    {
      int i;
      boolean drawLine = true; // alternate between dashes and gaps
   
      /*
        Figure out x and y distances for each of the spacing values
        I decided to trade memory for time; I'd rather allocate
        a few dozen bytes than have to do a calculation every time
        I draw.
      */
      for (i = 0; i < spacing.length; i++)
      {
        xSpacing[i] = lerp(0, (x1 - x0), spacing[i] / distance);
        ySpacing[i] = lerp(0, (y1 - y0), spacing[i] / distance);
      }
   
      i = 0;
      while (drawn < distance)
      {
        if (drawLine)
        {
          canvas.line(x0, y0, x0 + xSpacing[i], y0 + ySpacing[i]);
        }
        x0 += xSpacing[i];
        y0 += ySpacing[i];
        /* Add distance "drawn" by this line or gap */
        drawn = drawn + mag(xSpacing[i], ySpacing[i]);
        i = (i + 1) % spacing.length;  // cycle through array
        drawLine = !drawLine;  // switch between dash and gap
      }
    }
  }
   
  /*
   * Draw a dashed line with given dash and gap length.
   * x0 starting x-coordinate of line.
   * y0 starting y-coordinate of line.
   * x1 ending x-coordinate of line.
   * y1 ending y-coordinate of line.
   * dash - length of dashed line in pixels
   * gap - space between dashes in pixels
   */
  public void dashline(float x0, float y0, float x1, float y1, float dash, float gap, PGraphics canvas)
  {
    float [ ] spacing = { dash, gap };
    dashline(x0, y0, x1, y1, spacing, canvas);
  }

}
