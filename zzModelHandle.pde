// Toxiclib vector math
import toxi.math.conversion.*;
import toxi.geom.*;
import toxi.math.*;
import toxi.geom.mesh2d.*;
import toxi.util.datatypes.*;
import toxi.util.events.*;
import toxi.geom.mesh.subdiv.*;
import toxi.geom.mesh.*;
import toxi.math.waves.*;
import toxi.util.*;
import toxi.math.noise.*;

import processing.pdf.*;
import processing.dxf.*;

import remixlab.proscene.*;
import java.util.Iterator;
import java.util.Map;

// SETTINGS
boolean TESTRUN = false;

// GLOBALS

public zzModel model;

Scene scene;
Camera camera;

// SETTINGS
float DRAWING_SCALE_A4 = 0.567; // 1mm = 2.835 px 
float PANEL_THICKNESS = 1.8;

float DIY_PANEL_THICKNESS = 1.8; // in cm
float RC_PANEL_THICKNESS = 8.6; // in cm

boolean run = true;

public void setup()
{
   // GRAPHICS
   size(800,600, P3D);
   background(255);
   
   printInput(); 
   
   if(checkArgumentsInput())
   {
     // inladen van system geom
     String cpL = null;
     String cpWL = null;
     String cpRo = null;
     String cpWR = null;
     String cpR = null;
     
     
     // -Dgeom=<string>
     //String geomString = System.getProperty("geom");
     //String[] geomArr = geomString.split(" ");
     
       cpL = System.getProperty("cpl");
       cpWL = System.getProperty("cpwl");
       cpRo = System.getProperty("cpro");
       cpWR = System.getProperty("cpwr");
       cpR = System.getProperty("cpr");
       
     // get thickness of RC
     float rcth = 0.0;
     rcth = Float.parseFloat(System.getProperty("rcth")); // in cm
     
     if(rcth > 0.0)
     {
         RC_PANEL_THICKNESS = rcth / 10.0;
         println("RC THICKNESS: " +  RC_PANEL_THICKNESS);
     }
     
     setupScene();
     
     model = new zzModel(cpL, cpWL, cpRo, cpWR, cpR);
   }
   else 
   {
      if(!TESTRUN)
      {
        println("EXIT");
        run = false; 
        exit();
      }
      else {
        run = true;
      
        // TESTRUN: continue
      
       // schuin
       /*
       String cpL = "10.28991510855053,-241.15966043420212,0@41.159660434202124,-189.71008489144947,0@92.60923597695478,-220.57983021710106,0@123.47898130260637,-169.1302546743484,0@174.92855684535903,-200,0@205.79830217101062,-148.55042445724735,0@257.2478777137633,-179.42016978289894,0@288.11762303941487,-127.97059424014628,0@339.5671985821675,-158.84033956579788,0@370.4369439078191,-107.39076402304522,0@421.88651945057177,-138.26050934869681,0"; //@452.75626477622336,-86.81093380594416,0"; 
       String cpWL = "10.28991510855053,-241.15966043420212,117.57359312880715@41.159660434202124,-189.71008489144947,94.16666666666667@92.60923597695478,-220.57983021710106,105.90692646214048@123.47898130260637,-169.1302546743484,82.5@174.92855684535903,-200,94.24025979547382@205.79830217101062,-148.55042445724735,70.83333333333334@257.2478777137633,-179.42016978289894,82.57359312880715@288.11762303941487,-127.97059424014628,59.16666666666667@339.5671985821675,-158.84033956579788,70.90692646214049@370.4369439078191,-107.39076402304522,47.5@421.88651945057177,-138.26050934869681,59.24025979547382"; //@452.75626477622336,-86.81093380594416,35.83333333333334";
       String cpRo = "10.28991510855053,0.015935358388560417,358.74918892139783@41.159660434202124,-0.06337577905804892,283.81337577905805@92.60923597695478,-0.11081619972759427,326.37594047951393@123.47898130260637,-0.1901273371742036,251.44012733717418@174.92855684535903,-0.23756775784372053,294.0026920376301@205.79830217101062,-0.3168788952903583,219.0668788952903@257.2478777137633,-0.3643193159598468,261.62944359574624@288.11762303941487,-0.44363045340648455,186.69363045340646@339.5671985821675,-0.4910708740760015,229.25619515386234@370.4369439078191,-0.570382011522625,154.32038201152258@421.88651945057177,-0.6178224321921562,196.88294671197843"; //@452.75626477622336,-0.6971335696387655,121.94713356963872";
       String cpWR = "10.28991510855053,241.19153115097924,117.57359312880715@41.159660434202124,189.58333333333334,94.16666666666667@92.60923597695478,220.3581978176459,105.90692646214048@123.47898130260637,168.75,82.5@174.92855684535903,199.52486448431256,94.24025979547382@205.79830217101062,147.91666666666666,70.83333333333334@257.2478777137633,178.69153115097922,82.57359312880715@288.11762303941487,127.08333333333331,59.16666666666667@339.5671985821675,157.85819781764587,70.90692646214049@370.4369439078191,106.24999999999997,47.5@421.88651945057177,137.02486448431253,59.24025979547382"; //@452.75626477622336,85.41666666666664,35.83333333333334";   
       String cpR = "10.28991510855053,241.19153115097924,0@41.159660434202124,189.58333333333334,0@92.60923597695478,220.3581978176459,0@123.47898130260637,168.75,0@174.92855684535903,199.52486448431256,0@205.79830217101062,147.91666666666666,0@257.2478777137633,178.69153115097922,0@288.11762303941487,127.08333333333331,0@339.5671985821675,157.85819781764587,0@370.4369439078191,106.24999999999997,0@421.88651945057177,137.02486448431253,0@452.75626477622336,85.41666666666664,0";
       */
        /*
        String cpL = "0,-242.42640687119285,0@42.42640687119285,-200,0@84.8528137423857,-242.42640687119285,0@127.27922061357856,-200,0@169.7056274847714,-242.42640687119285,0@212.13203435596427,-200,0@254.55844122715712,-242.42640687119285,0@296.98484809834997,-200,0@339.4112549695428,-242.42640687119285,0@381.8376618407357,-200,0@424.26406871192853,-242.42640687119285,0";
        String cpWL = "0,-242.42640687119285,117.57359312880715@42.42640687119285,-200,100@84.8528137423857,-242.42640687119285,117.57359312880715@127.27922061357856,-200,100@169.7056274847714,-242.42640687119285,117.57359312880715@212.13203435596427,-200,100@254.55844122715712,-242.42640687119285,117.57359312880715@296.98484809834997,-200,100@339.4112549695428,-242.42640687119285,117.57359312880715@381.8376618407357,-200,100@424.26406871192853,-242.42640687119285,117.57359312880715";
        String cpRo = "0,0,360@42.42640687119285,0,300@84.8528137423857,0,360@127.27922061357856,0,300@169.7056274847714,0,360@212.13203435596427,0,300@254.55844122715712,0,360@296.98484809834997,0,300@339.4112549695428,0,360@381.8376618407357,0,300@424.26406871192853,0,360";
        String cpWR = "0,242.42640687119285,117.57359312880715@42.42640687119285,200,100@84.8528137423857,242.42640687119285,117.57359312880715@127.27922061357856,200,100@169.7056274847714,242.42640687119285,117.57359312880715@212.13203435596427,200,100@254.55844122715712,242.42640687119285,117.57359312880715@296.98484809834997,200,100@339.4112549695428,242.42640687119285,117.57359312880715@381.8376618407357,200,100@424.26406871192853,242.42640687119285,117.57359312880715";
        String cpR = "0,242.42640687119285,0@42.42640687119285,200,0@84.8528137423857,242.42640687119285,0@127.27922061357856,200,0@169.7056274847714,242.42640687119285,0@212.13203435596427,200,0@254.55844122715712,242.42640687119285,0@296.98484809834997,200,0@339.4112549695428,242.42640687119285,0@381.8376618407357,200,0@424.26406871192853,242.42640687119285,0";
        */
        // schuin andere kant
        /*
        String cpL = "-11.059115506714232,-105.95968706190456,0@40.959687061904575,-76.05911550671422,0@70.86025861709491,-128.07791807533303,0@122.87906118571372,-98.17734652014269,0@152.77963274090408,-150.1961490887615,0@204.7984353095229,-120.29557753357116,0@234.69900686471323,-172.31438010218997,0@286.71780943333204,-142.41380854699963,0@316.6183809885224,-194.43261111561844,0@368.6371835571412,-164.5320395604281,0@398.5377551123316,-216.5508421290469,0@450.5565576809504,-186.65027057385657,0";
        String cpWL = "-11.059115506714232,-105.95968706190456,219.78375843203708@40.959687061904575,-76.05911550671422,200@70.86025861709491,-128.07791807533303,219.78375843203708@122.87906118571372,-98.17734652014269,200@152.77963274090408,-150.1961490887615,219.78375843203708@204.7984353095229,-120.29557753357116,200@234.69900686471323,-172.31438010218997,219.78375843203708@286.71780943333204,-142.41380854699963,200@316.6183809885224,-194.43261111561844,219.78375843203708@368.6371835571412,-164.5320395604281,200@398.5377551123316,-216.5508421290469,219.78375843203708@450.5565576809504,-186.65027057385657,200";
        String cpRo = "-11.059115506714232,0.02597532869280883,308.71628865406706@40.959687061904575,0.09544224664288947,263.9012613233108@70.86025861709491,0.21685982197857356,327.43585924764227@122.87906118571372,0.2863267399286542,282.62083191688606@152.77963274090408,0.4077443152643241,346.15542984121754@204.7984353095229,0.47721123321443315,301.34040251046133@234.69900686471323,0.598628808550103,364.8750004347928@286.71780943333204,0.6680957265002121,320.0599731040366@316.6183809885224,0.789513301835882,383.594571028368@368.6371835571412,0.858980219785991,338.77954369761187@398.5377551123316,0.9803977951216609,402.31414162194335@450.5565576809504,1.0498647130717416,357.4991142911871";
        String cpWR = "-11.059115506714232,106.01163771929018,219.78375843203708@40.959687061904575,76.25,200@70.86025861709491,128.51163771929018,219.78375843203708@122.87906118571372,98.75,200@152.77963274090408,151.01163771929018,219.78375843203708@204.7984353095229,121.25000000000003,200@234.69900686471323,173.5116377192902,219.78375843203708@286.71780943333204,143.75000000000003,200@316.6183809885224,196.0116377192902,219.78375843203708@368.6371835571412,166.25000000000006,200@398.5377551123316,218.5116377192902,219.78375843203708@450.5565576809504,188.75000000000006,200";
        String cpR = "-11.059115506714232,106.01163771929018,0@40.959687061904575,76.25,0@70.86025861709491,128.51163771929018,0@122.87906118571372,98.75,0@152.77963274090408,151.01163771929018,0@204.7984353095229,121.25000000000003,0@234.69900686471323,173.5116377192902,0@286.71780943333204,143.75000000000003,0@316.6183809885224,196.0116377192902,0@368.6371835571412,166.25000000000006,0@398.5377551123316,218.5116377192902,0@450.5565576809504,188.75000000000006,0";
        */
        
        // GREET
        String cpL = "0,-174.68205795278573,0@42.42640687119285,-132.25565108159287,0@84.8528137423857,-174.68205795278573,0@127.27922061357856,-132.25565108159287,0@169.7056274847714,-174.68205795278573,0@212.13203435596427,-132.25565108159287,0@254.55844122715712,-174.68205795278573,0@296.98484809834997,-132.25565108159287,0@339.4112549695428,-174.68205795278573,0@381.8376618407357,-132.25565108159287,0@424.26406871192853,-174.68205795278573,0@466.6904755831214,-132.25565108159287,0";
        String cpWL = "0,-174.68205795278573,220.2363580178561@42.42640687119285,-132.25565108159287,200@84.8528137423857,-174.68205795278573,220.2363580178561@127.27922061357856,-132.25565108159287,200@169.7056274847714,-174.68205795278573,220.2363580178561@212.13203435596427,-132.25565108159287,200@254.55844122715712,-174.68205795278573,220.2363580178561@296.98484809834997,-132.25565108159287,200@339.4112549695428,-174.68205795278573,220.2363580178561@381.8376618407357,-132.25565108159287,200@424.26406871192853,-174.68205795278573,220.2363580178561@466.6904755831214,-132.25565108159287,200 ";
        String cpRo = "0,0,361.69109943366686@42.42640687119285,0,307.0985145456839@84.8528137423857,0,361.69109943366686@127.27922061357856,0,307.0985145456839@169.7056274847714,0,361.69109943366686@212.13203435596427,0,307.0985145456839@254.55844122715712,0,361.69109943366686@296.98484809834997,0,307.0985145456839@339.4112549695428,0,361.69109943366686@381.8376618407357,0,307.0985145456839@424.26406871192853,0,361.69109943366686@466.6904755831214,0,307.0985145456839";
        String cpWR = "0,174.68205795278573,220.2363580178561@42.42640687119285,132.25565108159287,200@84.8528137423857,174.68205795278573,220.2363580178561@127.27922061357856,132.25565108159287,200@169.7056274847714,174.68205795278573,220.2363580178561@212.13203435596427,132.25565108159287,200@254.55844122715712,174.68205795278573,220.2363580178561@296.98484809834997,132.25565108159287,200@339.4112549695428,174.68205795278573,220.2363580178561@381.8376618407357,132.25565108159287,200@424.26406871192853,174.68205795278573,220.2363580178561@466.6904755831214,132.25565108159287,200 ";
        String cpR = "0,174.68205795278573,0@42.42640687119285,132.25565108159287,0@84.8528137423857,174.68205795278573,0@127.27922061357856,132.25565108159287,0@169.7056274847714,174.68205795278573,0@212.13203435596427,132.25565108159287,0@254.55844122715712,174.68205795278573,0@296.98484809834997,132.25565108159287,0@339.4112549695428,174.68205795278573,0@381.8376618407357,132.25565108159287,0@424.26406871192853,174.68205795278573,0@466.6904755831214,132.25565108159287,0 ";
        
        setupScene();
        
        model = new zzModel(cpL, cpWL, cpRo, cpWR, cpR);
      }
   }
}

public void draw()
{
   if(run)
   {
     // GRAPHICS
     background(240);
     //smooth(); // smooth
     lightFalloff(1.0, 0.0005, 0.0);
     lightSpecular(20, 40, 20);
     pointLight(255,255,255, -200, 400, 600); // top
     pointLight(100,100,50, -600, 600, 1000); // top
     pointLight(150, 150, 150, -100, 0, 100); // inside
    
     model.draw();
     
     // EXPORT
     model.exporter.outputScreen("model.png");
     model.exporter.toPDF();
     model.exporter.toDXF();
     
     if(!TESTRUN)
       exit();
     else 
       noLoop();
   }
} 

public boolean checkArgumentsInput()
{
      /* -- USE SYSTEM geom ---*/
      /*
      
       if(args.length != 5)
      {
         return false; 
      }
      else
      {
         return true;
      }
      */
      
      if(System.getProperty("cpl") != null)
      {
          return true;
      }
      else {
        return false;}
}

public void printInput()
{
    // PRINT ARGS
    if(args.length > 0)
      println("=> INPUT ARGS:");
    else 
      println("=> NO INPUT ARGS:");
    
    for(int c = 0; c < args.length; c++)
    {
        println("=> args[" + c + "] = " + args[c]);
    }
    
    // PRINT SYSTEM PROPS
    println("SYSTEM GEOM");
    println(System.getProperty("cpl"));   
    println(System.getProperty("cpwl"));   
    println(System.getProperty("cpro"));   
    println(System.getProperty("cpwr"));   
    println(System.getProperty("cpr"));   
  
}
public void setupScene()
{
   // SETUP SCENE (PROSCENE)
   scene = new Scene(this);
      
   camera = new Camera(scene);
   
   scene.setCamera(camera);
   scene.setAxisIsDrawn(false);
   scene.setGridIsDrawn(false);
   scene.setRadius(5000);
   scene.showAll();
   
   // set position
   camera.setUpVector(new PVector(0,0,-1));
   camera.setPosition(new PVector(-550, 500, 200));
   camera.lookAt(new PVector(200,0,200));
} 

// for 1.5.1 instead of heading
public float vectorHeading(PVector v)
{
    float a = atan(abs(v.y) / abs(v.x));
    
    return a;
}
