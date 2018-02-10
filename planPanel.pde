public class planPanel
{
   ArrayList poly = new ArrayList();
   Line2D sourceLine;
   String name;
   public String side;
   public String direction;
   
   public planPanel(ArrayList pnts, String n)
   {
      poly = pnts;
      name = n;

      sourceLine = new Line2D((Vec2D) poly.get(0), (Vec2D) poly.get(1));
   }
   
   public void drawAt(float xoffset, float yoffset, float s, PGraphics canvas)
   {
      canvas.pushStyle();

      // draw original line
      //canvas.strokeWeight(1);
      //canvas.stroke(0xFF666666);
      //canvas.line(sourceLine.a.x * s + xoffset , sourceLine.a.y * s + yoffset , sourceLine.b.x * s + xoffset, sourceLine.b.y * s + yoffset );
      
      canvas.stroke(0xFF000000);
      canvas.noFill();
      canvas.strokeWeight(0.4);
      canvas.beginShape(); 

      for(int c = 0; c < poly.size(); c++)
      {
        Vec2D p = (Vec2D) poly.get(c);
        canvas.vertex(p.x * s + xoffset,p.y * s + yoffset);
      }
      
      canvas.endShape(CLOSE);
     
      
      canvas.popStyle();
   }
   
  public PVector getFirstPoint()
  {
      // transform to PVector (Polys are in PVectors) 
       return getPointIndex(0);
  }
  
  public PVector getLastPoint()
  {
      // transform to PVector (Polys are in PVectors) 
       return getPointIndex(poly.size() - 1);
  }
  
  public PVector getPointIndex(int i)
  {
      return new PVector((  (Vec2D) poly.get(i)).x, (  (Vec2D) poly.get(i)).y); 
  }
  
  public float getAngle()
  {
      PVector p1 = getPointIndex(0);
      PVector p2 = getPointIndex(1);
      
      float a = atan( ( (p2.y - p1.y) *  -1) / (p2.x - p1.x)) * 180 / PI; // screen angle (switch y directions
      
      return a;
    
  }
  public void extend(float offset)
  {
     // EXTENDS POLY TO RIGHT
     Vec2D pointLeft = (Vec2D) poly.get(0);
     Vec2D pointRight = (Vec2D) poly.get(1);
     Vec2D pointRightSec = (Vec2D) poly.get(2);
     
     Vec2D directionVector = pointRight.sub(pointLeft).normalize();
  
     // replace old coordinates
     pointRight = pointRight.add(directionVector.scale(offset));
     pointRightSec = pointRightSec.add(directionVector.scale(offset));
     
     poly.set(1, pointRight);
     poly.set(2, pointRightSec);
     
  }
  
  public void shorten(float offset)
  {
      // SHORTEN POLY TO LEFT
     Vec2D pointLeft = (Vec2D) poly.get(0);
     Vec2D pointRight = (Vec2D) poly.get(1);
     Vec2D pointLeftSec = (Vec2D) poly.get(3);
     
     Vec2D directionVector = pointRight.sub(pointLeft).normalize();
  
     // replace old coordinates
     pointLeft = pointLeft.add(directionVector.scale(offset));
     pointLeftSec = pointLeftSec.add(directionVector.scale(offset));
     
     poly.set(0, pointLeft);
     poly.set(3, pointLeftSec);
     
  }
}
