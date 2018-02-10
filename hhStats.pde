// holds and calculates all different variables
// can also plot them

public class Stats 
{
   // SETTINGS
   float COST_FLOORBEAMS = 5.5; // EUR / m ; 45x145 mm
   float COST_FLOORPANEL = 12.0; // EUR / m2
   float COST_PANEL = 18.0; // EUR / m2
   float COST_VERTICALPROFILE =  5.0; // EUR / m 50x100 + 50x50
   float COST_WATERPROOFING =  6.0; // EUR / m2
   float COST_FACADE = 20.0; // EUR / m2
   
   float COST_ENTRANCE = 1500;
   
   // cost calculations RC
   float COST_RC_PANEL = 50; // per gross panel surface
   float COST_RC_FLOORPANEL = 57; // per floor gross area
   float COST_RC_PANEL_MODS = 20; // per panel
   float COST_RC_FLOORPANEL_MODS = 20; // per floorpanel
   float COST_FACADE_TOTAL = 30;
   
   // cost calculations POIROT
   float COST_POIROT_RIB = 4.5; // material euro per meter
   float COST_POIROT_PANEL_MAT = 18; // OSB 18 + EPS 50
   float COST_POIROT_PANEL_LAB = 30.0; // euro per panel
   float COST_POIROT_FLOORBEAMS = 5.5; // euro per m
   float COST_POIROT_FLOOR_LAB = 40; // per segment
   float COST_POIROT_FLOOR_MAT = 30; // OSB 12 + EPS 11 + SP 7   
   
  
   public zzModel model;
  
   // design params
   HashMap<String,Float> design = new HashMap<String,Float>();
   // usage stats
   HashMap<String,Float> usage = new HashMap<String,Float>();
   // construction stats
   HashMap<String,Float> construction = new HashMap<String,Float>();
   // economy stats
   HashMap<String,Float> economy = new HashMap<String,Float>();
  
   HashMap<String,HashMap> stats; // in sets: set is a hashmap
  
   public Stats(zzModel m)
   {
      // constructor 
      model = m;
      
      stats = new HashMap<String, HashMap>();
   }
   
   public void update()
   {
       // update stats
      
       // design params 
       getDesignStats();
       getUsageStats();
       getConstructionStats();
       getEconomyStats();
   }
   
   public void getDesignStats()
   {
       design.put("entrance width", ((Vec3D) model.zzPointsLeft.get(0)).distanceTo( (Vec3D) model.zzPointsRight.get(0) ) );
       design.put("back width", ((Vec3D) model.zzPointsLeft.get(model.zzPointsLeft.size() - 1)).distanceTo( (Vec3D) model.zzPointsRight.get(model.zzPointsLeft.size() - 1) ) );
       design.put("depth", float (int ( ((Vec3D) model.zzPointsLeft.get(model.zzPointsLeft.size() - 1)).x - ((Vec3D) model.zzPointsLeft.get(0) ).x )));
       design.put("segment size",( (Vec3D) model.zzPointsLeft.get(0)).distanceTo( (Vec3D) model.zzPointsLeft.get(1) ) );
       design.put("roof angle", model.getRoofAngle()  );
       design.put("entrance height",  model.getWallHeight() );
       design.put("back height",  model.getWallBackHeight() );
       
       stats.put("design", design);
       
   }
   
   public void getUsageStats()
   {
      usage.put("gross area", calculateArea() ); 
      usage.put("max width",  float ( calculateMaxWidth()) );
      usage.put("min width" , float ( calculateMinWidth()) );
      usage.put("min height", float ( calculateMinHeight()) ) ;
      usage.put("max height", float ( calculateMaxHeight()) );
      usage.put("depth",  float ( int ( ((Vec3D) model.zzPointsLeft.get(model.zzPointsLeft.size() - 1)).x - ((Vec3D) model.zzPointsLeft.get(0) ).x )));
  
      stats.put("usage", usage);    
   }
   
   public void getConstructionStats()
   {
      construction.put("panels", float ( (model.zzPointsLeft.size() - 1) * 4));
      construction.put("panel width", ((Vec3D) model.zzPointsLeft.get(0)).distanceTo( (Vec3D) model.zzPointsLeft.get(1) ) );
      construction.put("max wall height", float (calculateMaxWallHeight() ) );
      construction.put("max roof length",  float ( calculateMaxRoofLength() ));
      construction.put("max span", float ( calculateMaxWidth() ));
      construction.put("total portal length (m)", float ( calculateTotalPortalLength() ) );
      construction.put("total panel area (m2)" , float ( calculateTotalPanelArea() ) );
      construction.put("floorbeams total (m)", float (calculateTotalFloorBeamLength()) );
      
      stats.put("construction", construction);    
   }
   
   public void getEconomyStats()
   {
       economy.put("cost floor deck", calculateArea() * COST_FLOORPANEL);
       economy.put("cost panels", calculateTotalPanelArea() * COST_PANEL);
       economy.put("cost floorbeams", calculateTotalFloorBeamLength() * COST_FLOORBEAMS);
       economy.put("cost verticals", calculateTotalPortalLength() * COST_VERTICALPROFILE );
       economy.put("cost waterproofing", calculateTotalPanelArea() * COST_WATERPROOFING );
       economy.put("cost facade", calculateTotalPanelArea() * COST_FACADE );
       economy.put("base material costs per m2", ( economy.get("cost floor deck") + economy.get("cost panels") + economy.get("cost floorbeams") + economy.get("cost verticals") ) / usage.get("gross area") ); 
       
       stats.put("economy", economy);    
   }
   public float calculateArea()
   {
       // return in m2
       // trapezium: steeds zigzag offset van basis en korte zijde aftrekken
       
       float zzDepth = ((Vec3D) model.zzPointsLeft.get(0)).distanceTo( (Vec3D) model.zzPointsLeft.get(1) )  / sqrt(2.0);
       println(zzDepth);
       float angle = atan ( abs ( ((Vec3D) model.zzPointsLeft.get(2)).y - ((Vec3D) model.zzPointsLeft.get(0)).y)  / ( ((Vec3D) model.zzPointsLeft.get(2)).x - ((Vec3D) model.zzPointsLeft.get(0)).x));
       println(angle * 180.0 / PI);
       float zzOffset =  abs ( zzDepth / cos(angle) ) ;
       println(zzOffset);
       
       float a = ((Vec3D) model.zzPointsLeft.get(0)).distanceTo( (Vec3D) model.zzPointsRight.get(0) ) - zzOffset;
       float b = ((Vec3D) model.zzPointsLeft.get(model.zzPointsLeft.size() - 1)).distanceTo( (Vec3D) model.zzPointsRight.get(model.zzPointsLeft.size() - 1) ) - zzOffset;
       float d = ((Vec3D) model.zzPointsLeft.get(model.zzPointsLeft.size() - 1)).x - ((Vec3D) model.zzPointsLeft.get(0) ).x;
       
       int area = int ( d * (a + b) / 2 / 1000 );
       float areaDecimal = area / 10.0; // 1 decimal
       
       return areaDecimal;
   }
   
   public float calculateAreaGross()
   {
         // return in m2
       
       float a = ((Vec3D) model.zzPointsLeft.get(0)).distanceTo( (Vec3D) model.zzPointsRight.get(0) );
       float b = ((Vec3D) model.zzPointsLeft.get(model.zzPointsLeft.size() - 1)).distanceTo( (Vec3D) model.zzPointsRight.get(model.zzPointsLeft.size() - 1) );
       float d = ((Vec3D) model.zzPointsLeft.get(model.zzPointsLeft.size() - 1)).x - ((Vec3D) model.zzPointsLeft.get(0) ).x;
       
       int area = int ( d * (a + b) / 2 / 1000 );
       float areaDecimal = area / 10.0; // 1 decimal
       
       return areaDecimal;
   }
   
   public int calculateMaxWidth()
   {
       float wf = ( (Vec3D) model.zzPointsLeft.get(0)).distanceTo( (Vec3D) model.zzPointsRight.get(0) );
       float wb = ( (Vec3D) model.zzPointsLeft.get(model.zzPointsLeft.size() - 1)).distanceTo( (Vec3D) model.zzPointsRight.get(model.zzPointsLeft.size() - 1) );
       
       if(wf > wb)
         return int (wf);
       else 
         return int (wb); 
   }
   public int calculateMinWidth()
   {
       float wf = ((Vec3D) model.zzPointsLeft.get(0)).distanceTo( (Vec3D) model.zzPointsRight.get(0) );
       float wb = ((Vec3D) model.zzPointsLeft.get(model.zzPointsLeft.size() - 1)).distanceTo( (Vec3D) model.zzPointsRight.get(model.zzPointsLeft.size() - 1) );
       
       if(wf < wb)
         return int (wf);
       else 
         return int (wb); 
     
   }
   
   public float calculateDepth()
   {
       return float (int ( ((Vec3D) model.zzPointsLeft.get(model.zzPointsLeft.size() - 1)).x - ((Vec3D) model.zzPointsLeft.get(0) ).x ));
   }
   
   public int calculateMaxHeight()
   {
       float hf =  ((Vec3D) model.zzPointsRoof.get(0)).z;
       float hb = ((Vec3D) model.zzPointsRoof.get(model.zzPointsRoof.size() - 1)).z;
       
       if(hf > hb)
         return int (hf);
       else 
         return int (hb); 
   }
   
   public int calculateMaxRoofLength()
   {
      int maxRl = 0;
     
      for(int p = 0; p < model.zzPointsWallLeft.size(); p++)
      {
         float rl =  ((Vec3D) model.zzPointsWallLeft.get(p)).distanceTo( (Vec3D) model.zzPointsRoof.get(p) );
         
         if(rl > maxRl)
         {
           maxRl = int ( rl );
         }
      }
      
      return maxRl;
   }
   
   public int calculateTotalPanelArea()
   {
       // simple: rectanglar area
       float areaSum = 0;
       
       for(int p = 0; p < model.panelsWallLeft.size(); p++)
       {
          areaSum += ((geomPanel) model.panelsWallLeft.get(p)).getArea();
          areaSum += ((geomPanel) model.panelsRoofLeft.get(p)).getArea();
       }
       
       return int ( areaSum * 2 ); // symmetry 
       
   }
   public int calculateMaxWallHeight()
   {
       float hf =  ((Vec3D) model.zzPointsWallLeft.get(0)).z;
       float hb = ((Vec3D) model.zzPointsWallLeft.get(model.zzPointsRoof.size() - 1)).z;
       
       if(hf > hb)
         return int (hf);
       else 
         return int (hb); 
   }
   
   public int calculateMinWallHeight()
   {
       float hf =  ((Vec3D) model.zzPointsWallLeft.get(0)).z;
       float hb = ((Vec3D) model.zzPointsWallLeft.get(model.zzPointsRoof.size() - 1)).z;
       
       if(hf < hb)
         return int (hf);
       else 
         return int (hb); 
   }
   
   public int calculateMinHeight()
   {
       float hf =  ((Vec3D) model.zzPointsRoof.get(0)).z;
       float hb = ((Vec3D) model.zzPointsRoof.get(model.zzPointsRoof.size() - 1)).z;
       
       if(hf < hb)
         return int (hf);
       else 
         return int (hb); 
   }
   
   public int calculateTotalPortalLength()
   {
      int sum = 0;
     
      for(int p = 0; p < model.zzPointsWallLeft.size(); p++)
      {
         float wl = ((Vec3D) model.zzPointsLeft.get(p)).distanceTo( (Vec3D) model.zzPointsWallLeft.get(p) );
         float rl =  ((Vec3D) model.zzPointsWallLeft.get(p)).distanceTo( (Vec3D) model.zzPointsRoof.get(p) );
         
         sum += int ( wl + rl );
      }    
     
      return sum * 2 / 100; // in m
   }
   
   public int calculateTotalFloorBeamLength()
   {
       int sum = 0;
       
      for(int p = 0; p < model.zzPointsWallLeft.size(); p++)
      {
         float w = ((Vec3D) model.zzPointsLeft.get(p)).distanceTo( (Vec3D) model.zzPointsRight.get(p) );
         
         if(p != 0 || p != model.zzPointsWallLeft.size() -1)
         {
             w *= 2.0; // two beams side to side
         }
         
         sum += w;
      }   
     
      float segmentSize = ((Vec3D) model.zzPointsLeft.get(0)).distanceTo( (Vec3D) model.zzPointsLeft.get(1) );
     
      return int ( (sum + segmentSize * (model.zzPointsWallLeft.size() - 1) * 2) / 100.0); // to do: end beams
   }
   
   public void print(String setName)
   {
       HashMap set = (HashMap) stats.get(setName);
      
       printHashMap(set);
   }
   
   void printHashMap(HashMap hm)
   {
        Iterator i = hm.entrySet().iterator();  // Get an iterator

        while (i.hasNext())
        {
          Map.Entry me = (Map.Entry) i.next();
          
          println(me.getKey() + " = " + me.getValue());
        }
   }
   
   void drawSetOn(int x, int y, String setName, PGraphics canvas)
   {
      // use Table to draw the stats
      HashMap set = (HashMap) stats.get(setName);
      
      Table table = new Table(set.size(), 2 , 140);
      table.fontSize = 6;
      table.rowHeight = 8;
      table.setTitle(setName);
      
      Iterator i = set.entrySet().iterator();  // Get an iterator
      
      int c = 0;

      while (i.hasNext())
      {
          Map.Entry me = (Map.Entry) i.next();
          
          String[] rowArr = {  me.getKey() + " " , str ( (Float) me.getValue()) };
          
          table.setRow(c, rowArr);
          
          c++;
      }
      
      table.roundValues();
      table.setPosition(x,y);
      table.drawOn(canvas);
   }
   
} 
