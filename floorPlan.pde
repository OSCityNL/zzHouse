public class floorPlan
{
   /*********************************/
   /*
   /*  draws floorplan
   /*    2 building methods: DIY or RC
   /*
   /*********************************/
   
   float BEAM_WIDTH = 4.4; // 44 mm
   color BEAM_FILL = 0xFFDDDDDD;
   color BEAM_STROKE = 0xFF000000;
   
   float[][] VERTICAL_PROFILE  = { {0,0},{5,0},{5,5},{10,5},{10,10},{0,10}};
   float[][] VERTICAL_PROFILE_HALF  = { {0,0},{5,0},{5,10},{0,10}};
   
   // scale
   float drawScale = 1.0;
   
   // some parts to re-use
   public Poly contourOutside = new Poly();
   
  
   public zzModel model;
   
   String buildingMethod = "DIY"; // DIY or RC
   float panelThickness;
  
   ArrayList wallLeftPanels = new ArrayList();
   ArrayList wallRightPanels = new ArrayList();
   
   public floorPlan(zzModel m, String type, float sc)
   {
      // CREATE FLOORPLAN FROM CONSTRUCTION
      drawScale = sc;
      model = m;
      buildingMethod = type;
      
      if(buildingMethod == "DIY")
        panelThickness = DIY_PANEL_THICKNESS;
      else
        panelThickness = RC_PANEL_THICKNESS;
      
      for(int s = 0; s < model.panelsWallLeft.size(); s++)
      {
         geomPanel panel = (geomPanel) model.panelsWallLeft.get(s);
          
         wallLeftPanels.add(panel.panelToFloorplanPoly(panelThickness));
      }
          
      for(int s = 0; s < model.panelsWallRight.size(); s++)
      {
         geomPanel panel = (geomPanel) model.panelsWallRight.get(s);
         
         wallRightPanels.add(panel.panelToFloorplanPoly(panelThickness));
       }
   }
   
   public void drawAt(float x, float y, PGraphics canvas)
   {
      Poly drawnVertical;
     
      // CONTOUR
      //drawContour(new PVector(x,y), 0, canvas);
     
      // LEFT WALL
      planPanel prevPanel = null;
      
      for(int c = 0; c < wallLeftPanels.size(); c++)
      {
         planPanel pnl = (planPanel) wallLeftPanels.get(c);
        
         pnl.drawAt(x,y,drawScale,canvas); 
         
         // vertical
         if(buildingMethod == "DIY")
         {
         
           if( pnl.direction == "IN" )
           {
             if(prevPanel != null)
             { 
                //drawVertical("FULL",  PVector.add(PVector.mult(prevPanel.getPointIndex(1), drawScale), new PVector(x,y)), 2, pnl.getAngle(), canvas);  // <== OK This could be better: scaling position
                //  - 135
                if(c == wallLeftPanels.size() - 1)
                {
                    // last panel
                    drawnVertical = drawVertical("HALF" , PVector.add(PVector.mult(pnl.getPointIndex(1), drawScale), new PVector(x,y)), 3, pnl.getAngle() + 90, canvas);
                    //contourOutside.addPoint(drawnVertical.points[1]);
                    contourOutside.addPoint(drawnVertical.points[2]);  
                }
             }
             else 
             {
              // first panel
              drawnVertical = drawVertical("HALF" , PVector.add(PVector.mult(pnl.getPointIndex(0), drawScale), new PVector(x,y)), 0, pnl.getAngle() + 90, canvas);
              contourOutside.addPoint(PVector.add(PVector.mult(pnl.getPointIndex(3), drawScale), new PVector(x,y)));
              contourOutside.addPoint(drawnVertical.points[0]);
              contourOutside.addPoint(drawnVertical.points[1]);
              // - 135 
             } 
           }
           else 
           {
             // OUT
              // type | position | align point index | angle | canvas
             drawnVertical = drawVertical( "FULL" , PVector.add(PVector.mult(pnl.getPointIndex(0), drawScale), new PVector(x,y)), 5, pnl.getAngle(), canvas); // in
             contourOutside.addPoint(drawnVertical.points[2]);
             
             if(c == 0)
             {
                 // first 
             }
             else if(c == wallRightPanels.size() - 1)
             {
                 // last
                 drawnVertical = drawVertical("HALF" , PVector.add(PVector.mult(pnl.getPointIndex(1), drawScale), new PVector(x,y)), 3, pnl.getAngle() + 90, canvas);
                 contourOutside.addPoint(drawnVertical.points[2]);
                 contourOutside.addPoint(drawnVertical.points[3]);  
                 contourOutside.addPoint(PVector.add(PVector.mult(pnl.getPointIndex(2), drawScale), new PVector(x,y)));
             }
             else 
             {
               drawnVertical = drawVertical( "FULL" , PVector.add(PVector.mult(pnl.getPointIndex(1), drawScale), new PVector(x,y)), 2, pnl.getAngle() + 180, canvas); // out
               contourOutside.addPoint(drawnVertical.points[5]);
             }  
           }
           
           prevPanel = pnl;
         }
         else 
         {
           // RC panels method
           // get simple contour with panels for RC method
           PVector p0 = pnl.getPointIndex(0).get();
           PVector p1 = pnl.getPointIndex(1).get();
           PVector p2 = pnl.getPointIndex(2).get();
           PVector p3 = pnl.getPointIndex(3).get();
           
           p0.add(new PVector(x,y));
           p1.add(new PVector(x,y));
           p2.add(new PVector(x,y));
           p3.add(new PVector(x,y));
           
           if(c == 0)
           {
              // first
              contourOutside.addPoint(p3);
              contourOutside.addPoint(p0);
           }
           else if(c == wallRightPanels.size() - 1)
           {
              // last 
              if(pnl.direction == "OUT")
                  contourOutside.addPoint(p0);

              contourOutside.addPoint(p1);
              
              if(pnl.direction == "OUT")
                  contourOutside.addPoint(p2);
           }
           else 
           {
             // normal
             if(pnl.direction == "OUT")
             {  
                 contourOutside.addPoint(p0);
                 contourOutside.addPoint(p1);
             }
           }
         }
      }
      // RIGHT WALL : TO DO: Combine these loops
      
      prevPanel = null;
      
      for(int c = wallRightPanels.size() - 1; c >= 0; c--)
      {
        // LET OP: loop andere kant op!
         planPanel pnl = (planPanel) wallRightPanels.get(c);
        
         pnl.drawAt(x,y,drawScale,canvas); 
         
         // vertical (ONLY WITH DIY)
         if(buildingMethod == "DIY")
         {
           if( pnl.direction == "IN" )
           {
             if(c == 0)
             {
                       // first panel
                      drawnVertical = drawVertical("HALF" , PVector.add(PVector.mult(pnl.getPointIndex(0), drawScale), new PVector(x,y)), 1, pnl.getAngle() + 90, canvas);
                      contourOutside.addPoint(drawnVertical.points[0]);
                      contourOutside.addPoint(drawnVertical.points[1]);
                      contourOutside.addPoint(PVector.add(PVector.mult(pnl.getPointIndex(3), drawScale), new PVector(x,y)));
             }
             else if (c == wallLeftPanels.size() - 1)
             {
                 // last panel
                 drawnVertical = drawVertical("HALF" , PVector.add(PVector.mult(pnl.getPointIndex(1), drawScale), new PVector(x,y)), 2, pnl.getAngle() + 90, canvas);
                 contourOutside.addPoint(drawnVertical.points[3]);
             }
             else {
                 // everything normal get done with out 
             }
           }
           else 
           {
             // OUT
             
             if(c == 0)
             {
                 // first 
             }
             else if(c == wallRightPanels.size() - 1)
             {
                 // last
                 contourOutside.addPoint(PVector.add(PVector.mult(pnl.getPointIndex(2), drawScale), new PVector(x,y)));
                 drawnVertical = drawVertical("HALF" , PVector.add(PVector.mult(pnl.getPointIndex(1), drawScale), new PVector(x,y)), 2, pnl.getAngle() + 90, canvas);
                 contourOutside.addPoint(drawnVertical.points[2]);
                 contourOutside.addPoint(drawnVertical.points[3]); 
             }
             else 
             {
               // in between    
               drawnVertical = drawVertical( "FULL" , PVector.add(PVector.mult(pnl.getPointIndex(1), drawScale), new PVector(x,y)), 2, pnl.getAngle() + 90, canvas); // out
               contourOutside.addPoint(drawnVertical.points[5]);
               
             }
             
             drawnVertical = drawVertical( "FULL" , PVector.add(PVector.mult(pnl.getPointIndex(0), drawScale), new PVector(x,y)), 5, pnl.getAngle() - 90, canvas); // in
             contourOutside.addPoint(drawnVertical.points[2]);
           }          
             
           prevPanel = pnl;
         }
         else 
         {
           // RC panels method
           // get simple contour with panels for RC method
           PVector p0 = pnl.getPointIndex(0).get();
           PVector p1 = pnl.getPointIndex(1).get();
           PVector p2 = pnl.getPointIndex(2).get();
           PVector p3 = pnl.getPointIndex(3).get();
           
           p0.add(new PVector(x,y));
           p1.add(new PVector(x,y));
           p2.add(new PVector(x,y));
           p3.add(new PVector(x,y));
           
           if(c == 0)
           {
              // first
              contourOutside.addPoint(p0);
              contourOutside.addPoint(p3);
           }
           else if(c == wallRightPanels.size() - 1)
           {
              // last
              if(pnl.direction == "OUT")
                contourOutside.addPoint(p2);
                
              contourOutside.addPoint(p1);
              
              if(pnl.direction == "OUT"){
                  contourOutside.addPoint(p0);}
           }
           else 
           {
             // normal
             if(pnl.direction == "OUT")
             {  
                 contourOutside.addPoint(p1);
                 contourOutside.addPoint(p0);
             }
           }
         }
      }
      
      // contour
      contourOutside.setStyle(0x00666666, 0xFF000000, 0.7);
      contourOutside.drawOn(canvas);
      
      model.stats.update();
      //model.stats.print("design");
      
      model.stats.print("construction");
      
   }
   
   public void drawFloorConstructionOffset(float x, float y, PGraphics canvas)
   {
        // TRANSLATION: canvas.translate doesn't seem to work: use move of poly class
        // everything is done from the contour of the plan: just move that
     
        boolean DRAW_DXF = false;
  
        if(canvas.getClass().toString().equals("class processing.dxf.RawDXF"))
          DRAW_DXF = true;
          
        contourOutside.move(x,y); // Translate contour to move everything 
        contourOutside.drawOn(canvas);
        
        
        // calculate vectors along contour
        PVector p1 = contourOutside.points[1];
        PVector p2 = contourOutside.points[2];
        PVector p3 = contourOutside.points[3];
        
        PVector OffsetToLeft = PVector.sub(p1,p2);
        PVector OffsetToRight = PVector.sub(p3,p2);
        
        PVector[] upperPoints = contourOutside.getUpperPoints();
        PVector[] lowerPoints = contourOutside.getLowerPoints();

        //println(upperPoints);
        //println(lowerPoints);
        
        canvas.stroke(0xFFFF0000);
        
        Poly previousBeam = null;
       
        for(int p = 0; p < upperPoints.length; p++)
        {
            PVector pntLeft = upperPoints[p];
            PVector pntRight = lowerPoints[lowerPoints.length - p - 1];
          
            PVector previousPoint = null;
            PVector nextPoint = null;
            
            if(p != 0)
              previousPoint = upperPoints[p - 1];
            if(p != upperPoints.length -1)
              nextPoint =  upperPoints[p + 1];
            
            Poly drawnBeamLeft = null;
            Poly drawnBeamRight = null;
            
            if(p > 1 && p < upperPoints.length - 2)
            {
                if(previousPoint != null)
                {
                  // draw left beam
                  drawnBeamLeft = drawFloorBeam(pntLeft, pntRight, PVector.sub(previousPoint, pntLeft), canvas);
                }
                
                if(nextPoint != null)
                {
                  // draw right beam
                  drawnBeamRight = drawFloorBeam(pntLeft, pntRight, PVector.sub(nextPoint, pntLeft), canvas);
                }
                
                // draw sides
                if(previousBeam != null)
                {
                    // left side
                    Poly sideLeft = new Poly();
                    sideLeft.addPoint(previousBeam.points[1]);
                    sideLeft.addPoint(drawnBeamLeft.points[1]);
                    float offset = -BEAM_WIDTH * drawScale / cos( abs ( vectorHeading( PVector.sub(previousPoint, pntLeft) ) ) ) ;
                    sideLeft.addPoint(PVector.add(drawnBeamLeft.points[1], new PVector(0,-offset)));
                    sideLeft.addPoint(PVector.add(previousBeam.points[1], new PVector(0,-offset)));
                    
                    sideLeft.setStyle(BEAM_FILL, BEAM_STROKE, 0.5);
                    sideLeft.drawOn(canvas);
                    
                    
                    // right side
                    Poly sideRight = new Poly();
                    sideRight.addPoint(previousBeam.points[2]);
                    sideRight.addPoint(drawnBeamLeft.points[2]);
                    sideRight.addPoint(PVector.add(drawnBeamLeft.points[2], new PVector(0,offset)));
                    sideRight.addPoint(PVector.add(previousBeam.points[2], new PVector(0, offset)));
                    
                    sideRight.setStyle(BEAM_FILL, BEAM_STROKE, 0.5);
                    sideRight.drawOn(canvas);
                    
                    // balancers
                    canvas.pushStyle();
                    
                    if(DRAW_DXF)
                      canvas.noFill();
                    else
                      canvas.fill(BEAM_FILL);
                      
                    canvas.stroke(BEAM_STROKE);
                    canvas.strokeWeight(0.5);
                    
                    // left
                    if(sideLeft.points[2].y < sideLeft.points[3].y)
                    {
                        if(DRAW_DXF)
                        {
                          Poly balanceRect = new Poly();
                          balanceRect.rectangle(sideLeft.points[3].x, sideLeft.points[3].y, sideLeft.points[2].x - sideLeft.points[3].x, BEAM_WIDTH * drawScale);
                          balanceRect.drawOn(canvas);
                        }
                        else
                          canvas.rect(sideLeft.points[3].x, sideLeft.points[3].y, sideLeft.points[2].x - sideLeft.points[3].x, BEAM_WIDTH * drawScale);
                    }
                    else 
                    {
                        if(DRAW_DXF)
                        {
                          Poly balanceRect = new Poly();
                          balanceRect.rectangle(sideLeft.points[2].x, sideLeft.points[2].y, sideLeft.points[3].x - sideLeft.points[2].x, BEAM_WIDTH * drawScale);
                          balanceRect.drawOn(canvas);
                        }
                        else
                         canvas.rect(sideLeft.points[2].x, sideLeft.points[2].y, sideLeft.points[3].x - sideLeft.points[2].x, BEAM_WIDTH * drawScale);
                    }
                    
                    // right
                    if(sideRight.points[2].y > sideRight.points[3].y)
                    {
                        if(DRAW_DXF)
                        {
                          Poly balanceRect = new Poly();
                          balanceRect.rectangle(sideRight.points[3].x, sideRight.points[3].y, sideRight.points[2].x - sideRight.points[3].x, -BEAM_WIDTH * drawScale);
                          balanceRect.drawOn(canvas);
                        }
                        else
                          canvas.rect(sideRight.points[3].x, sideRight.points[3].y, sideRight.points[2].x - sideRight.points[3].x, -BEAM_WIDTH * drawScale);
                    }
                    else 
                    {
                        if(DRAW_DXF)
                        {
                          Poly balanceRect = new Poly();
                          balanceRect.rectangle(sideRight.points[2].x, sideRight.points[2].y, sideRight.points[3].x - sideRight.points[2].x, -BEAM_WIDTH * drawScale);
                          balanceRect.drawOn(canvas);
                        }
                        else
                           canvas.rect(sideRight.points[2].x, sideRight.points[2].y, sideRight.points[3].x - sideRight.points[2].x, -BEAM_WIDTH * drawScale);
                    }
                    
                    // center 
                    float pivotY = contourOutside.getPivot().y;
                    
                    if(DRAW_DXF)
                    {
                          Poly balanceRect = new Poly();
                          balanceRect.rectangle(sideLeft.points[0].x, pivotY + BEAM_WIDTH * drawScale * 0.5, sideLeft.points[1].x - sideLeft.points[0].x, BEAM_WIDTH * drawScale);
                          balanceRect.drawOn(canvas);
                    }
                    else 
                      canvas.rect(sideLeft.points[0].x, pivotY + BEAM_WIDTH * drawScale * 0.5, sideLeft.points[1].x - sideLeft.points[0].x, BEAM_WIDTH * drawScale);

                    
                    canvas.popStyle();
                    
                }
            }
          
            previousBeam = drawnBeamRight;
        }
   }
   
   public float getWidth()
   {
       return abs ( ((planPanel) wallLeftPanels.get(wallLeftPanels.size() - 1)).getPointIndex(2).x - ((planPanel) wallLeftPanels.get(0)).getFirstPoint().x);
   }
   
   public Poly drawVertical(String type, PVector position, int alignPointIndex, float d, PGraphics canvas)
   {
       Poly v;
     
       if(type != "HALF")
         v = new Poly(VERTICAL_PROFILE);
       else 
         v = new Poly(VERTICAL_PROFILE_HALF);
       
       v.setStyle(0xFF666666, 0xFF000000, 0.5);
       v.rotateAroundInternalPoint(0,d);
       v.scaleFromInternalPoint(0, drawScale);
       v.alignPointToPoint(alignPointIndex, position);
       
       v.drawOn(canvas);
     
       // return poly that has been drawn
       return v;
   }
   
   public Poly drawFloorBeam(PVector left, PVector right, PVector offsetVector, PGraphics canvas)
   {
       Poly beam = new Poly();


       float a = vectorHeading(offsetVector); //.heading(); 
       float tl = abs(BEAM_WIDTH * drawScale / cos(a));
       offsetVector.normalize();
       offsetVector.mult(tl);

       beam.addPoint(left);
       beam.addPoint(PVector.add(left, offsetVector));
       beam.addPoint(PVector.add(right, new PVector(offsetVector.x, -1 * offsetVector.y)));
       beam.addPoint(right);
       
       beam.setStyle(BEAM_FILL, BEAM_STROKE, 0.5);
       beam.drawOn(canvas);
       
       return beam;
       
   }
   
   public void drawContour(PVector beginPosition, float offset, PGraphics canvas)
   {
      // array to hold points
      
      Poly contour = new Poly(); // empty poly: add points later
      contour.setStyle(0xFFEEEEEE, 0xFF000000, 0.5);
     
      for(int p = 0; p < wallLeftPanels.size(); p++)
      { 
          planPanel pnl = (planPanel) wallLeftPanels.get(p);
          
          Vec2D firstPoint = (Vec2D) pnl.poly.get(0);
          Vec2D secondPoint = (Vec2D) pnl.poly.get(1);
       
         if(pnl.direction == "OUT")
         {
          contour.addPointVec2D(firstPoint); // do all panels (overlapping points: lazy)
          contour.addPointVec2D(secondPoint);
         }
         else {
           // only first point
           contour.addPointVec2D(firstPoint);
           // except last one
           if(p == wallLeftPanels.size() - 1)
           {
             contour.addPointVec2D(secondPoint);
           }
         }
          
      }
      // IMPROVE THIS
      for(int p = wallRightPanels.size() - 1; p >= 0; p--)
      {
          planPanel pnl = (planPanel) wallRightPanels.get(p);
          
          Vec2D firstPoint = (Vec2D) pnl.poly.get(0);
          Vec2D secondPoint = (Vec2D) pnl.poly.get(1);
          
         if(pnl.direction == "OUT")
         {
          contour.addPointVec2D(secondPoint);
          contour.addPointVec2D(firstPoint); // do all panels (overlapping points: lazy)
         }
         else {
           // only first point
           // except last one
           if(p == wallLeftPanels.size() - 1)
           {
             contour.addPointVec2D(secondPoint);
           }
           
           contour.addPointVec2D(firstPoint);
         }
      }
      
      
      contour.scaleFromInternalPoint(0, drawScale);
      contour.alignPointToPoint(0, beginPosition);
      contour.drawOn(canvas);
      //contour.offsetY(   DIY_PANEL_THICKNESS / cos(PI/2 - abs(atan((contour.points[0].y - contour.points[1].y) / (contour.points[0].x - contour.points[1].x))))  );
      //contour.drawOn(canvas);
   }
}
