// panel

public class geomPanel 
{
  // SETTINGS
  float PANEL_THICKNESS = 1.8; 
  
  // main geometry
  public Vec3D p1Bottom;
  public Vec3D p2Bottom;
  public Vec3D p1Top;
  public Vec3D p2Top;
  
  // property values
  public float panelWidth;
  public float panelHeight;
  public float panelHeightMax;
  public float panelHeightMin;
  
  public float topAngle;
  public float bottomAngle;
  
  // arrayList of points (to draw poly)
  ArrayList panelPoly = new ArrayList();
  
  public Vec2D panelFlatLeftBottom;
  public Vec2D panelFlatRightBottom; // LET OP: scherm is y - gespiegeld
  
  zzModel model;
  
  String direction; // "IN / OUT"
  String type; // WALLLEFT, WALLRIGHT, ROOFLEFT, ROOFRIGHT
  String name;
  boolean isFirst = false; // true/false
  boolean isLast = false;
  
  public geomPanel prevPanel;
  public geomPanel nextPanel;

  public geomPanel(Vec3D p1, Vec3D p2, Vec3D p3, Vec3D p4, String t, String n, zzModel m)
  {
      p1Bottom = p1;
      p2Bottom = p2;
      
      p1Top = p3;
      p2Top = p4;

      model = m;
      type = t;
      name = n;

      // get point in poly array      
      panelPoly.add(p1);
      panelPoly.add(p2);
      panelPoly.add(p4);
      panelPoly.add(p3);
      
      // track direction: inside or outside
      if(p2Top.z > p1Top.z)
        direction = "OUT";
      else 
        direction = "IN";
      
      // calculate width and of the panel
      Line3D l1 = new Line3D (p1,p3);
      Line3D l2 = new Line3D (p2,p4);
      
      panelHeight = l1.getLength();
      if(l2.getLength() > panelHeight)
      {
         panelHeight = l2.getLength();
         panelHeightMin = l1.getLength();
      }
      else {
        panelHeightMin = l2.getLength();
      }
     
      panelHeightMax = panelHeight;
      
      l1.a = l1.a.sub(l1.getDirection().scale(l1.getLength()));

      panelWidth = (l1.closestPointTo(p2).distanceTo(p2));
      
      // angle of top / bottom
      // DIT KLOPT NIET: wnat in 3d ruimte geompanel
      //topAngle = atan ( abs(p1Top.z - p2Top.z) / panelWidth ) * 180 / PI; 
      topAngle = acos ( panelWidth / p1Top.distanceTo(p2Top)) * 180.0 / PI;
      bottomAngle = atan ( abs(p1Bottom.z - p2Bottom.z) / panelWidth ) * 180.0 / PI;  
      
      //println("TOPANGLE: " + topAngle + " D" + p1Top.distanceTo(p2Top) + " W " + panelWidth + " C " + acos ( panelWidth / p1Top.distanceTo(p2Top)));
      //println("BOTTOMANGLE: " + bottomAngle);
  }
  
  public float getArea()
  {
      // simple in m2
      return panelHeight * panelWidth / 10000;
  }
  public void draw()
  {
      // general draw
      drawOn(g);          
  }
  
  public void drawOn(PGraphics canvas)
  {
     if(canvas.is3D())
     {
         // do some 3d drawing
        boolean DRAW_DXF = false;
        
        if(canvas.getClass().toString().equals("class processing.dxf.RawDXF"))
          DRAW_DXF = true;
         
        // draw panel in 3d
        canvas.pushStyle();
          canvas.strokeWeight(model.MODEL_STROKEWEIGHT);
          canvas.fill(model.MODEL_FILLCOLOR);
          canvas.stroke(model.MODEL_STROKECOLOR);
          if(DRAW_DXF){
              canvas.noFill();
              canvas.beginShape(TRIANGLES);
              
              canvas.vertex(p1Bottom.x, p1Bottom.y, p1Bottom.z);
              canvas.vertex(p1Top.x, p1Top.y, p1Top.z);  
              canvas.vertex(p2Bottom.x, p2Bottom.y, p2Bottom.z);
              
              canvas.vertex(p1Top.x, p1Top.y, p1Top.z);
              canvas.vertex(p2Bottom.x, p2Bottom.y, p2Bottom.z);
              canvas.vertex(p2Top.x, p2Top.y, p2Top.z);
          }
          else {
            canvas.beginShape(QUAD_STRIP);
            canvas.vertex(p1Bottom.x, p1Bottom.y, p1Bottom.z);
            canvas.vertex(p2Bottom.x, p2Bottom.y, p2Bottom.z);
            canvas.vertex(p1Top.x, p1Top.y, p1Top.z);      
            canvas.vertex(p2Top.x, p2Top.y, p2Top.z);
          }
            
          canvas.endShape();
          
        canvas.popStyle();
     }
  }
  public Vec3D getNormal()
  {
     Vec3D w = p2Bottom.sub(p1Bottom);
     Vec3D h = p1Top.sub(p1Bottom);
     
     Vec3D n = w.cross(h).normalize();
     
     return n;
  }
  public panelFlat layOutCopy(String align)
  {
     ArrayList poly = new ArrayList(); // panel to return as array of points
     
     Vec3D zAxis = new Vec3D(0,0,1);
     Vec3D panelNormal = this.getNormal();
     
     //println("NORMAL" + panelNormal);
     
     float rotAngle = zAxis.angleBetween(panelNormal, true);
     Vec3D rotAxis = zAxis.cross(panelNormal).normalize();
       
     float align_xmin = 1000.0;
     float align_ymin = 1000.0;
       
     for(int c = 0; c < panelPoly.size(); c++)
     {
           Vec3D p = (Vec3D) panelPoly.get(c);
           Vec2D pp = p.getRotatedAroundAxis(rotAxis, -rotAngle).to2DXY();
           
           poly.add(pp); 
                  
     }
     
     // ALSO ALIGN VERTICAL OR HORIZONTAL
           Vec2D alignAxis = null;
           
           if(align == "VERTICAL")
             alignAxis = new Vec2D(1,0);
           else 
              alignAxis = new Vec2D(0,1);
              
     // CALCULATE ANGLE TO ROTATE FOR ALIGNMENT
     
     Vec2D pp1Bottom = (Vec2D) poly.get(0);
     Vec2D pp2Bottom = (Vec2D) poly.get(1);
     Vec2D pp1Top = (Vec2D) poly.get(3);
     Vec2D pp2Top = (Vec2D) poly.get(2);
              
     // println("LEFTBOTTOM" + pp1Bottom);
     // println("RIGHTBOTTOM" + pp2Bottom);
     // println("TOPLEFT" + pp1Top);
      //println("TOPRIGHT" + pp2Top);
              
      Line2D vl1 = new Line2D (pp1Bottom, pp1Top);
      Line2D vl2 = new Line2D (pp2Bottom, pp2Top);
      
      vl1.a = vl1.a.sub(vl1.getDirection().scale(vl1.getLength())); // extend
      
      //vl1.scale(2f);
      
      
      //println("VL " + vl.getLength());
      //println("VL2 " + vl2.getLength());


      Vec2D polyHorizontalAlign = pp2Bottom.sub(vl1.closestPointTo(pp2Bottom));
      
      //println("polyHorizontalAlign" + polyHorizontalAlign);
              
     //Vec2D polyHorizontalAlign = ((Vec2D) flatpanel.get(1)).sub((Vec2D) flatSegment.get(0));
    
     float alignAngle = alignAxis.angleBetween(polyHorizontalAlign, true); // JUST ROTATE 180 DEGREES STANDARD TO HAVE TOP AT THE TOP OF THE SCREEN
     
     if(polyHorizontalAlign.y < 0)
     {
        alignAngle *= -1;
     }
     
     Vec2D bottomLeftVector = (Vec2D) poly.get(0);
      
     for(int c = 0; c < poly.size(); c++)
     {
           // first align poly to 0,0 (with bottom left on origin)
           
           Vec2D pp = (Vec2D) poly.get(c);
           
           //println("P" + bottomLeftVector);
           
           pp = pp.sub(bottomLeftVector);
           
           pp = pp.getRotated(-alignAngle);
           
           // LET OP: alvast verticaal spiegelen
           //pp.y *= -1;
           
           poly.set(c, pp);

          
           // align: top (lowest y) left (min x)
           if(pp.x < align_xmin)
             align_xmin = pp.x;
           if(pp.y < align_ymin)
             align_ymin = pp.y;    
     }           
     
     
      // ALIGN POINTS 
    for(int c = 0; c < poly.size(); c++)
    {
         Vec2D pp = (Vec2D) poly.get(c);
         // align: bottom (highest y) left (min x)
         pp.x -= align_xmin;
         pp.y -= align_ymin;
         
    }
    
    panelFlatLeftBottom = (Vec2D) poly.get(0);
    panelFlatRightBottom = (Vec2D) poly.get(1);
    Vec2D panelFlatLeftTop = (Vec2D) poly.get(3);
    Vec2D panelFlatRightTop = (Vec2D) poly.get(2);
    
    /******** MN 17-08-2013 : use simple methode of calculating the cutting angle ********/
    /*    because angles between panels are 90 degrees the cutting angle of one is the same as the angle of the panel of the other 
    /*
    /*******************************************************/
    
    float cutAngleTop = atan( abs(panelFlatLeftTop.y - panelFlatRightTop.y) / abs(panelFlatLeftTop.x - panelFlatRightTop.x));  // ANGLE 2D
    float cutAngleBottom = atan( abs(panelFlatLeftBottom.y - panelFlatRightBottom.y) / abs(panelFlatLeftBottom.x - panelFlatRightBottom.x)); // ANGLE 2D
    
    //println("TOP CUT ANGLE" + cutAngleTop * 180/PI);
    //println("BOTTOM CUT ANGLE" + cutAngleBottom * 180/PI);
   
    //println("R ANGLE " + model.roofAngle);
    
    float cuttingAngleTop; // BOTTOM / TOP = IN REAL TERMS: OP PLAAT
    float cuttingAngleBottom;
    
    if(type == "ROOFLEFT" || type == "ROOFRIGHT")
    {
       // BUG: ROOFANGLE IS IN GRADEN => NAAR DEG
        cuttingAngleTop = atan( tan(model.roofAngle * PI/180.0) * cos(this.panelXAngle()) );  // NOK
      
        //println ( "ROOF ANGLE" + model.roofAngle );
        //println( " XANGLE" + this.panelXAngle());
        //println("ROOF CUT ANGLE TOP " + cuttingAngleTop);
        
        // !!!!!! CORRECTION DUE TO ALIGNMENT OF SAW ON DIAGONAL END !!!!!!!!
        cuttingAngleTop = round(atan(cos(cutAngleTop) * tan(cuttingAngleTop)) * 10.0 * 180.0/PI)/10.0;
        
       //println("ROOF CUT ANGLE TOP SAW" + cuttingAngleTop);
        
        // cuttingAngleBottom = round (atan( tan((PI/2.0 - parentPart.roofAngle)/2.0) / sqrt(2.0)) * 180.0/PI * 10.0)/10.0; 
        cuttingAngleBottom = atan( tan((PI/2.0 - model.roofAngle * PI/180.0)/2.0) * cos(this.panelXAngle()) ); 
        
        cuttingAngleBottom = round(atan(cos(cutAngleBottom) * tan(cuttingAngleBottom)) * 10.0 * 180.0/PI)/10.0;
        
    }
    else {
      // BUG: ROOFANGLE IS IN GRADEN => NAAR DEG
      cuttingAngleBottom = 0.0;
      // cuttingAngleTop = round (atan( tan((PI/2.0 - parentPart.roofAngle)/2.0) / sqrt(2.0)) * 180.0/PI * 10.0)/10.0; 
      
      cuttingAngleTop = atan( tan( (PI/2.0 - model.roofAngle * PI/180.0)/2.0) * cos(this.panelXAngle() ) ); 

      cuttingAngleTop = round(atan(cos(cutAngleTop) * tan(cuttingAngleTop)) * 10.0 * 180.0/PI)/10.0;
      
      //println("WALL CUT ANGLE TOP SAW" + cuttingAngleTop);
      
      //cuttingAngleTop = 
      
      //println("cuttingAngleTop " + this.panelXAngle() + "--" + cuttingAngleTop);
      
    }
    //*/
    
    //println("cuttingAngleTop" + cuttingAngleTop);
    //println("cuttingAngleBottom" + cuttingAngleBottom);
    
    /********* END OF OLD CUTTING ANGLE CALCULATION */
    
    /*
    // calculatue cutting angle: is angle of prev/next panel
    float cuttingAngleBottom = 0.0;
    float cuttingAngleTop = 0.0;
    
    if(!isFirst)
    {
       cuttingAngleTop = round(prevPanel.topAngle * 10.0) / 10.0; 
       cuttingAngleBottom = round(prevPanel.bottomAngle * 10.0) / 10.0;
    }
    else {
       cuttingAngleTop = round(nextPanel.topAngle * 10.0) / 10.0; 
       cuttingAngleBottom = round(nextPanel.bottomAngle * 10.0) / 10.0;
    }
    */
    return new panelFlat(poly, name, cuttingAngleTop, cuttingAngleBottom,  this.model);
  }
  
  public panelFlat layOutAndDrawOn(float x, float y, boolean ymir, panelFlat prevFlatPanel, PGraphics canvas, float thickness, float panelScale)
  {
      float panelThickness = thickness;
    
      // CREATE FLATTENED GEOMETRY
      panelFlat panel = layOutCopy("VERTICAL");
      
      // ALIGNMENT TO PREVIOUS PANEL
      Vec2D prevFlatPanelalignVector = new Vec2D(0,0);
      
      panel.alignToPanel(prevFlatPanel); // align
      
      if(prevFlatPanel != null)
      {
         isFirst = false;
      }
      else {
        // first panel
        isFirst = true;  
      }
      
      println("--" + model.startType + "--" + direction);
      
      if(model.startType == "IN")
      {  
          if(direction == "OUT")
          {
             // shorten
             panel.shorten(panelThickness);
             // extend
             panel.extend(panelThickness);
          }
      }
      if(model.startType == "OUT")
      {
         if(direction == "IN")
         {
           // extend
             panel.extend(panelThickness);
            // shorten
             panel.shorten(panelThickness);
         }  
        
      }
      
      // SCALE
      panel.panelScale(panelScale);
      
       // MIRROR
      if(ymir)
      {
          panel.mirror();
      }
      
      
      // PRINTOUT PANEL    
      panel.drawAt(x, y + prevFlatPanelalignVector.y, canvas);
      
      //panelFlatRightBottom.y -= prevFlatPanelalignVector.y;
      
      // RETURNS panelFlat
      return panel;
  }
  
  public float panelXAngle()
  {
   // 1st quandrant
   float a = atan(abs(p1Bottom.y - p2Bottom.y)/abs(p1Bottom.x - p2Bottom.x));
   return a;
  }
  
  public planPanel panelToFloorplanPoly(float offset)
  { 
      Vec2D offsetVector = null;
    
      // Check which side is inside
      if(type == "WALLLEFT")
          offsetVector = this.getNormal().to2DXY().normalize().getInverted();
      else 
        offsetVector = this.getNormal().to2DXY().normalize();
      
      // USE FIRST POINT OF CONSTRUCTION TO ALIGN PLAN LEFT UPPER CORNER
      Vec2D alignVector = model.getStartPoint();
      
      
      Vec2D p1Bottom2D = p1Bottom.to2DXY().sub(alignVector);
      Vec2D p2Bottom2D = p2Bottom.to2DXY().sub(alignVector);
      
      Vec2D p1Bottom2DExtended = p1Bottom2D.add(offsetVector.scale(offset));
      Vec2D p2Bottom2DExtended = p2Bottom2D.add(offsetVector.scale(offset));

      ArrayList poly = new ArrayList();
      poly.add(p1Bottom2D);
      poly.add(p2Bottom2D);
      poly.add(p2Bottom2DExtended);
      poly.add(p1Bottom2DExtended);
      
      planPanel panel = new planPanel(poly, name);
      
      panel.side = type;
      panel.direction = direction;
      
      if(model.startType == "OUT")
      {
        if(direction == "IN")
        {
          // extend
          if(!isLast)
            panel.extend(offset);
          if(!isFirst)
            panel.shorten(offset); // shorten
        }
      }
      else if(model.startType == "IN")
      {
          if(direction == "IN")
          {
            // shorten and extend
            if(!isLast){
                panel.extend(offset);}
                
            panel.shorten(offset);
          }
      }
      
      return panel;
  }
}
