public class Poly
{
   /***** 2D/3D Shape *******/
   /*
   /*  simple drawing of shapes and transformations
   /*  operates on real coordinates points (no paramaters like position)
   /*
   /***************************/ 
   
   public PVector[] points = new PVector[0]; // array of points 
   
   public int numPoints;
   public int dimensions; // 2 / 3 
   public boolean isClosed;
   
   // STYLING
   public color fillColor = 0xFFFFFFFF; // set default
   public color strokeColor = 0xFF000000;
   public float strokeWeight = 0.5; 
   
   public Poly()
   {
       // make empty poly: add points later

   }
   public Poly(float[][] pnts)
   {
      numPoints = pnts.length;
     
      points = new PVector[numPoints];
     
      // check dimensions
      dimensions = pnts[0].length; 
     
      for(int p = 0; p < pnts.length; p++)
      {
         if(dimensions == 2)
           points[p] = new PVector(pnts[p][0], pnts[p][1]);
         if(dimensions == 3)
           points[p] = new PVector(pnts[p][0], pnts[p][1],  pnts[p][2]);  
      }
   }
   
   public void rectangle(float x, float y, float w, float h)
   {
     // used for drawing with just lines
     addPoint(new PVector(x,y));
     addPoint(new PVector(x+w,y));
     addPoint(new PVector(x+w, y+h));
     addPoint(new PVector(x, y+h));
     addPoint(new PVector(x,y));
   }
   
   public void setStyle(color fc, color sc, float sw)
   { 
      fillColor = fc;
      strokeColor = sc;
      strokeWeight = sw;
   }
   
   public void draw()
   {
      // general draw
      PGraphics screen = g;
      
      drawOn(g);
   }
   
   public void alignPointToPoint(int pointIndex, PVector targetPoint)
   {
       // calculate offset vector
       if(pointIndex > points.length - 1)
         pointIndex = 0; // out of range: use first point
       
       PVector polyPoint = points[pointIndex];
       
       PVector offsetVector = PVector.sub(targetPoint, polyPoint);
       
       move(offsetVector);
   }
   
   public void move(PVector moveVector)
   {
       for(int p = 0; p < points.length; p++)
       {
          // move all points
          points[p].add(moveVector);
       }
   }
   
   public void move(float x, float y)
   {
       PVector moveVector = new PVector(x,y);
     
       for(int p = 0; p < points.length; p++)
       {
          // move all points
          points[p].add(moveVector);
       }
   }
   
   public void scale(float s)
   {
        for(int p = 0; p < points.length; p++)
       {
          // scale all points from origin
          points[p].mult(s);
       }
   }
   
   public void rotate(float d)
   {
       // simple rotate: against clock
       for(int p = 0; p < points.length; p++)
       {
          // move all points
          points[p].rotate(- d * PI / 180.0);
       }
   }
   public void rotateAroundPoint(PVector centerPoint, float deg)
   {
       // break link with point of poly:  because it will be transformed by rotate
       centerPoint = centerPoint.get();
     
       PVector moveVector = PVector.mult(centerPoint, -1.0);
       
       move(moveVector); // move centerpoint to origin
       rotate(deg);
       move(centerPoint);
     
   } 
   
   public void rotateAroundInternalPoint(int pointIndex, float deg)
   {
       if(pointIndex > points.length - 1)
         pointIndex = 0; // out of range: use first point
     
       PVector centerPoint = points[pointIndex];
       
       rotateAroundPoint(centerPoint, deg);
   } 
   
   public void scaleFromPoint(PVector centerPoint, float s)
   {
       // break link with point of poly:  because it will be transformed by rotate
       centerPoint = centerPoint.get();
     
       PVector moveVector = PVector.mult(centerPoint, -1.0);
       
       move(moveVector); // move centerpoint to origin
       scale(s);
       move(centerPoint);
   } 
   
   public void scaleFromInternalPoint(int pointIndex, float s)
   {
       if(pointIndex > points.length - 1)
         pointIndex = 0; // out of range: use first point
     
       PVector centerPoint = points[pointIndex];
       
       scaleFromPoint(centerPoint, s);
   } 
   
   public void drawOn(PGraphics canvas)
   {
      boolean primary = canvas.is3D(); // when 3d it is the primary screen 
     
      if(!primary)
        canvas.beginDraw();
      
      canvas.pushStyle();
      
      // DXF doesnt allow for fills
      if(canvas.getClass().toString().equals("class processing.dxf.RawDXF"))
        canvas.noFill();
      else
        canvas.fill(fillColor);
      
      canvas.stroke(strokeColor);
      canvas.strokeWeight(strokeWeight);
      canvas.beginShape();

      for(int p = 0; p < points.length; p++)
      {
        if(dimensions == 2)
            canvas.vertex(points[p].x, points[p].y);
        if(dimensions == 3)
            canvas.vertex(points[p].x, points[p].y, points[p].z);    
      }
      
      canvas.endShape(CLOSE);
      canvas.popStyle();
      
      if(!primary)
        canvas.endDraw();
      
   }
   
   public void addPoint(PVector pnt)
   {
       dimensions = 2;
     
       points = (PVector[]) append(points, pnt); 
   }
   
   public void addPointVec2D(Vec2D pnt)
   {   
       dimensions = 2;
     
       points = (PVector[]) append(points, new PVector(pnt.x, pnt.y)); 
   }
   
   public PVector getPivot()
   {
        float sumX = 0;
        float sumY = 0;
     
        for(int p = 0; p < points.length; p++)
        {
             sumX += points[p].x;
             sumY += points[p].y; 
        }
        
        // average
        return new PVector(sumX / points.length, sumY / points.length); 
   }
   
   public PVector[] getPointsUpDown(String side)
   {
       // side = UP / DOWN
       PVector[] sidePoints = new PVector[0];
       
       PVector pivot = getPivot();
     
       for(int p = 0; p < points.length; p++)
       {
           PVector pnt = points[p];
           
           if(side == "UP" && pivot.y > pnt.y)
             sidePoints = (PVector[]) append(sidePoints, pnt); // SomeClass[] items = (SomeClass[]) append(originalArray, element)
           
           if(side == "DOWN" && pivot.y < pnt.y){
             sidePoints = (PVector[]) append(sidePoints, pnt); // SomeClass[] items = (SomeClass[]) append(originalArray, element)
             //sidePoints = (PVector[]) reverse(sidePoints);
           }
       } 
   
       return sidePoints;     
   }
   
   public PVector[] getUpperPoints()
   {
      return getPointsUpDown("UP");
   }
   
   public PVector[] getLowerPoints()
   {
      return getPointsUpDown("DOWN");
   }
   
   public void offsetY(float offset)
   {
       // offset geometry in y direction
       PVector pivot = getPivot();
       
       for(int p = 0; p < points.length; p++)
       {
          if(points[p].y < pivot.y)
          {
               println("up");
               points[p].y -= offset;
          }
          else {
             points[p].y += offset;
          }
       }
   }
}
