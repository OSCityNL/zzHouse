public class zzModel
{
   // SETTINGS
   color MODEL_FILLCOLOR = 0xFF33AA33;
   color MODEL_STROKECOLOR = 0xFFFFFFFF;
   color MODEL_STROKEWEIGHT = 3;
  
   // property variables
   public ArrayList zzPointsLeft = new ArrayList();
   public ArrayList zzPointsWallLeft = new ArrayList();
   public ArrayList zzPointsRight = new ArrayList();
   public ArrayList zzPointsWallRight = new ArrayList();
   public ArrayList zzPointsRoof = new ArrayList();
   
   // ArrayList holds panel geometry (geomPanel)
   public ArrayList panelsWallLeft = new ArrayList();
   public ArrayList panelsRoofLeft = new ArrayList();
   public ArrayList panelsRoofRight = new ArrayList();
   public ArrayList panelsWallRight = new ArrayList();
   public ArrayList panelsFloor = new ArrayList();
   
   // HANDY PARAMETERS
   public float wallHeight;
   public float roofAngle;
   public float roofHeight;
   
   // STATS OBJ
   public Stats stats;
   
   String startType = "OUT"; // IN OR OUT (normally out);
   
   // objects
   Exporter exporter;
   
   
   // TODO: styling settings
   
   public zzModel(String cpL, String cpWL, String cpRo, String cpWR, String cpR)
   {
       // constructor: uses control points strings as input to create model from panels etc.
       // syntax: cpL=x1,y1,z1SEPx2,y2,z2SEPx3,y3,z3SEPx4,y4,z4
       
       exporter = new Exporter(this);
      
      // load control points from string
      zzPointsLeft = createArrayFromStringSep(cpL);
      zzPointsWallLeft = createArrayFromStringSep(cpWL);
      zzPointsRoof = createArrayFromStringSep(cpRo);
      zzPointsWallRight = createArrayFromStringSep(cpWR);
      zzPointsRight = createArrayFromStringSep(cpR);
      
      // DEBUG: output control points
      println(zzPointsLeft);
      println(zzPointsWallLeft);
      println(zzPointsRoof);
      println(zzPointsWallRight);
      println(zzPointsRight);
      
      // DEBUG: output panel width
      for(int c = 0; c < zzPointsLeft.size() - 1; c++)
      {
         Vec3D v1 = (Vec3D) zzPointsLeft.get(c);
         Vec3D v2 = (Vec3D) zzPointsLeft.get(c+1);
         
         println("PANEL W" + c + " " + v1.distanceTo(v2));
      }
      
      getParametersFromControlPoints();
      // FROM CONTROL POINT TO PANEL GEOMETRY
      createPanelsFromControlPoints();
      
      
      // CREATE STATS
      stats = new Stats(this);
   }
  
   public void getParametersFromControlPoints()
   {  
       // FILL IN PARAMETERS FROM CONTROLPOINTS ARRAYLISTS
       wallHeight = getWallHeight();
       roofHeight = getRoofHeight();
       roofAngle = getRoofAngle();
   }
   
   public float getWallHeight()
   {
       float wallHeight;
     
       // WALLHEIGHT IS THE OUTSIDE / heighest point on panel
       Vec3D p1 = (Vec3D) zzPointsWallLeft.get(0); // first wall left 
       Vec3D p2 = (Vec3D) zzPointsWallLeft.get(1); // second wall left
       
       if( p1.z > p2.z)
          wallHeight = p1.z;
       else
          wallHeight = p2.z;   
     
       return wallHeight;
   }
   
    public float getWallBackHeight()
   {
       float wallHeight;
     
       // WALLHEIGHT IS THE OUTSIDE / heighest point on panel
       Vec3D p1 = (Vec3D) zzPointsWallLeft.get(zzPointsWallLeft.size() - 1); // first wall left 
       Vec3D p2 = (Vec3D) zzPointsWallLeft.get(zzPointsWallLeft.size() - 2); // second wall left
       
       if( p1.z > p2.z)
          wallHeight = p1.z;
       else
          wallHeight = p2.z;   
     
       return wallHeight;
   }
   
   public float getRoofAngle()
   {
       Vec3D p1 = (Vec3D) zzPointsWallLeft.get(0); // first wall left 
       Vec3D p2 = (Vec3D) zzPointsRoof.get(0); // first roof top
     
       return abs( atan( (p2.z - p1.z) / (p1.y + p2.y) ) * 180 / PI );
   }  
   
   public float getRoofHeight()
   {
       Vec3D p1 = (Vec3D) zzPointsWallLeft.get(0); // first wall left 
       Vec3D p2 = (Vec3D) zzPointsRoof.get(0); // first roof top
     
       return p2.z - p1.z;
   }
   public float getLength()
   {
       Vec3D p1 = (Vec3D) zzPointsWallLeft.get(0); // first wall left 
       Vec3D p2 = (Vec3D) zzPointsWallLeft.get(zzPointsWallLeft.size() - 1 ); // last wall left 
       
       return p2.x - p1.x;
   }
   
   public int getNumPanels()
   {
       return (zzPointsWallLeft.size() - 1) * 4;
   }
   
   public void createPanelsFromControlPoints()
   {
         // make panels from control points
         
         // wall left
         for(int p = 0; p < zzPointsLeft.size() - 1; p++)
         {
            geomPanel wl = new geomPanel((Vec3D) zzPointsLeft.get(p), (Vec3D) zzPointsLeft.get(p+1), (Vec3D) zzPointsWallLeft.get(p), (Vec3D) zzPointsWallLeft.get(p+1), "WALLLEFT", "WL" + p, this);
            geomPanel rl = new geomPanel((Vec3D) zzPointsWallLeft.get(p), (Vec3D) zzPointsWallLeft.get(p+1), (Vec3D) zzPointsRoof.get(p), (Vec3D) zzPointsRoof.get(p+1), "ROOFLEFT", "RL" + p,  this);
            geomPanel rr = new geomPanel((Vec3D) zzPointsWallRight.get(p), (Vec3D) zzPointsWallRight.get(p+1), (Vec3D) zzPointsRoof.get(p), (Vec3D) zzPointsRoof.get(p+1), "ROOFRIGHT", "RR" + p, this);
            geomPanel wr = new geomPanel((Vec3D) zzPointsRight.get(p), (Vec3D) zzPointsRight.get(p+1), (Vec3D) zzPointsWallRight.get(p), (Vec3D) zzPointsWallRight.get(p+1), "WALLRIGHT", "WR" + p, this);
            
            geomPanel pwl = null;
            geomPanel prl = null;
            geomPanel prr = null;
            geomPanel pwr = null;
            
            if(p != 0)
            {
                pwl = (geomPanel) panelsWallLeft.get(panelsWallLeft.size() - 1);
                prl = (geomPanel) panelsRoofLeft.get(panelsRoofLeft.size() - 1);
                prr = (geomPanel) panelsRoofRight.get(panelsRoofRight.size() - 1);
                pwr = (geomPanel) panelsWallRight.get(panelsWallRight.size() - 1);
                
                pwl.nextPanel = wl;
                prl.nextPanel = rl;
                prr.nextPanel = rr;
                pwr.nextPanel = wr;
                
                wl.prevPanel = pwl;
                rl.prevPanel = prl;
                rr.prevPanel = prr;
                wr.prevPanel = pwr;
            }
            else 
            {
              wl.isFirst = true;
              rl.isFirst = true;
              rr.isFirst = true;
              wr.isFirst = true;
            }
           
            panelsWallLeft.add(wl);
            panelsRoofLeft.add(rl);
            panelsRoofRight.add(rr);
            panelsWallRight.add(wr);
         } 
         
         createFloor();
         
         println("=> Created geometry panels");
   }
   
   public ArrayList createArrayFromStringSep(String s)
   {
      String COORDPAIR_SEPERATOR = "@";
      String COORD_SEPERATOR = ",";
      
      String[] coordStrings = split(s,COORDPAIR_SEPERATOR);
      ArrayList coords = new ArrayList();
      
      for(int c = 0; c < coordStrings.length; c++)
      {
         String[] cs = split(coordStrings[c], COORD_SEPERATOR);
        
         coords.add(new Vec3D( float(cs[0]), float(cs[1]), float(cs[2]) ) );
      }
      
      // return arrayList of coords (Vec3D)
      return coords;
   }
   
   public void draw()
   {
       drawOn(g);
   }
   
   public void drawOn(PGraphics canvas)
   {
       // SIMPLE GEOMETRY DRAW IN 3D
       for(int p = 0; p < panelsWallLeft.size(); p++)
       {
           geomPanel panelWL = (geomPanel) panelsWallLeft.get(p);
           geomPanel panelRL = (geomPanel) panelsRoofLeft.get(p);
           geomPanel panelRR = (geomPanel) panelsRoofRight.get(p);
           geomPanel panelWR = (geomPanel) panelsWallRight.get(p);
           
           // draw 
           panelWL.drawOn(canvas);
           panelRL.drawOn(canvas);
           panelRR.drawOn(canvas);
           panelWR.drawOn(canvas);
       }
      
       drawFloorOn(canvas);  
   }
   public void drawFloorOn(PGraphics canvas)
   {
       for(int p = 0; p < panelsFloor.size(); p++)
       {
            geomPanel panel = (geomPanel) panelsFloor.get(p);
           
            panel.drawOn(canvas); 
       }
       
       // DRAW PLANE (only on screen)
       if(!canvas.getClass().toString().equals("class processing.dxf.RawDXF"))
         drawFloorPlane(100000,0x22000000);
   }
   
   public void drawFloorPlane(int s, color c)
   {
      pushStyle();
      noStroke();
      fill(c);
      beginShape();
      vertex(s/2, -s/2, -1);
      vertex(s/2,  s/2, -1);
      vertex(-s/2, s/2, -1);
      vertex(-s/2, -s/2, -1);
      endShape(); 
      popStyle();   
   }
   
   public void createFloor()
   {
       for(int p = 0; p < zzPointsLeft.size() - 1; p++)
       {
           Vec3D cpLeft1 = (Vec3D) zzPointsLeft.get(p);
           Vec3D cpLeft2 = (Vec3D) zzPointsLeft.get(p+1);
           
           Vec3D cpRight1 = (Vec3D) zzPointsRight.get(p);
           Vec3D cpRight2 = (Vec3D) zzPointsRight.get(p+1);
            
           panelsFloor.add(new geomPanel(cpLeft1, cpLeft2, cpRight1, cpRight2, "FLOOR" , "F" + p, this));    
       }
   }
   
   public Vec2D getStartPoint()
   {
       // function used for alignment of plan
       // TODO    
       Vec3D p = (Vec3D) zzPointsLeft.get(0);
       return new Vec2D(p.x, p.y); 
   }
   
   public float getLargestSpan()
   {
       float span = -1f;
       Vec3D pl;
       Vec3D pr;
       float d;
     
       for(int p = 0;  p < zzPointsLeft.size(); p++)
       {
           pl = (Vec3D) zzPointsLeft.get(p);
           pr = (Vec3D) zzPointsRight.get(p);
          
           d = pl.distanceTo(pr);
          
           if(d > span)
            span = d; 
       }
       
       return span;
   }
   
}
