public class Exporter
{
    // SETTINGS
   float BEAM_WIDTH = 4.4; // 44 mm
   color BEAM_FILL = 0xFFDDDDDD;
   color BEAM_STROKE = 0xFF000000;
   
   // SETTINGS
   float LAYOUTOFFSET_X = 30;
   float LAYOUTOFFSET_Y = 30;
   float XMARGIN = 10.0;
   float YMARGIN = 10.0;
  
   public zzModel model; // total model
   
   floorPlan plan;
  
   public Exporter(zzModel m)
   { 
      //
      model = m;
   }
   
   public void toDXF()
   {
      // HINT: DXF Y COORDINATE IS REVERSED
     
      int MARGIN = 200;
      
      println("=> EXPORT TO DXF"); 
      
      String filename = insertFrame("model.dxf");
      
      PGraphics dxfFile = createGraphics(5000, 5000, DXF, filename);
      g.beginRaw(dxfFile);
      
        // floorplan DIY
        plan = new floorPlan(model, "DIY", 1.0);
        plan.drawAt(800, 700, dxfFile);
        
        // floorcontruction DIY
        float Xoffset = plan.getWidth();
        
        plan.drawFloorConstructionOffset(Xoffset + MARGIN, 0, dxfFile);
        
        // panels DIY
        float rowPosition = -300; // draw position 
        float panelThickness = DIY_PANEL_THICKNESS;
        
        rowPosition += printPanelCollection(model.panelsWallLeft, dxfFile, 2000, rowPosition, panelThickness, 1.0) + YMARGIN; // functions returns height of drawn model
        rowPosition += printPanelCollection(model.panelsRoofLeft, dxfFile, 2000, rowPosition, panelThickness, 1.0) + YMARGIN;
        rowPosition += printPanelCollection(model.panelsRoofRight, dxfFile, 2000, rowPosition, panelThickness, 1.0) + YMARGIN;
        rowPosition += printPanelCollection(model.panelsWallRight, dxfFile, 2000, rowPosition, panelThickness, 1.0) + YMARGIN;
        
        // floorplan RC
        plan = new floorPlan(model, "RC", 1.0);
        plan.drawAt(800, 0, dxfFile);

        // floorcontruction RC
        plan.drawFloorConstructionOffset(Xoffset + MARGIN, 0, dxfFile);
        
        // 3D points / model
        model.drawOn(dxfFile);
        
        // RC panels on DXF
        rowPosition = 1000; // draw position 
        panelThickness = RC_PANEL_THICKNESS;
        
        rowPosition += printPanelCollection(model.panelsWallLeft, dxfFile, 2000, rowPosition, panelThickness, 1.0) + YMARGIN; // functions returns height of drawn model
        rowPosition += printPanelCollection(model.panelsRoofLeft, dxfFile, 2000, rowPosition, panelThickness, 1.0) + YMARGIN;
        rowPosition += printPanelCollection(model.panelsRoofRight, dxfFile, 2000, rowPosition, panelThickness, 1.0) + YMARGIN;
        rowPosition += printPanelCollection(model.panelsWallRight, dxfFile, 2000, rowPosition, panelThickness, 1.0) + YMARGIN;
      
      g.endRaw();
   }

   public void toPDF()
   { 
        println("=> EXPORT TO PDF");
        
        // PAGE 1: perspective + floorplan
        // PAGE 2: shopping list + tools
        // PAGE 3: floorconstruction buildup
        // PAGE 4: panels
        // PAGE 5: extra
        
        int THUMB_WIDTH = 160;
        int THUMB_HEIGHT = 110;
        
        int VIEW_WIDTH = 400;
        int VIEW_HEIGHT = 300;
        
        
        float x = LAYOUTOFFSET_X;
        float y = LAYOUTOFFSET_Y;
  
       
        // SCALE OUTPUT AS PDF 
        // IN PDF READER: 72 DPI => 1 PX = 0.35278 mm
        // => ILLUSTRATOR => DWG: OPENS 1 to 1
        
        //String pdfFilename = "zzhouse_" + day() + "_" + hour() + "-" + minute() + "-" + second() + ".pdf";
        
        
        /************************************************************/
        /*         PAGE 1                                           */
        /*                                                          */
        /************************************************************/
        
        String pdfPage1Filename = "manual_page1.pdf";
        
        PGraphics pdfPage1 = createGraphics( 842, 595, PDF, pdfPage1Filename);
        
        pdfPage1.beginDraw();
        pdfPage1.strokeWeight(0.5);
        
        // FLOORPLAN
        plan = new floorPlan(model, "DIY", DRAWING_SCALE_A4);
        plan.drawAt(500, 120, pdfPage1);
        drawScalebar(500, 420, 100, pdfPage1);
        
        // STAMP
        PShape stamp;
        stamp = loadShape("stamp.svg");
        pdfPage1.shape(stamp);
        // stats on the stamp
        int stampStatsX = 645;
        int stampStatsY = 530;
        int stampStatsFontsize = 7;
        pdfPage1.fill(0xFF000000);
        pdfPage1.textSize(stampStatsFontsize);
        
        pdfPage1.text("width =" + round(model.getLargestSpan()) + " cm | height = " + round(model.wallHeight + model.roofHeight) + " cm \ndepth = " + round(model.getLength()) + " cm | panels = " + model.getNumPanels() , stampStatsX, stampStatsY);
        
        // 3D VIEW
        
        PImage view;
        int VIEWX = 30;
        int VIEWY = 100;
        view = loadImage("model.png");
        view.resize(VIEW_WIDTH, VIEW_HEIGHT);
        pdfPage1.image(view, VIEWX, VIEWY);
        
        // STATS
        model.stats.drawSetOn(30, 430, "design", pdfPage1);
        model.stats.drawSetOn(190, 430, "usage", pdfPage1);
        model.stats.drawSetOn(350, 430, "construction", pdfPage1);
        
        // PAGE TITLE
        drawPageTitle("1. DESIGN", 20, "LEFT", "BOTTOM", pdfPage1);
        
        
        // FINISH PAGE 1 DRAWING
        pdfPage1.endDraw(); 
        pdfPage1.dispose();
        
        /************************************************************/
        /*         PAGE 2: preparation                              */
        /*                                                          */
        /************************************************************/
        
        String pdfPage2Filename = "manual_page2.pdf";
        
        PGraphics pdfPage2 = createGraphics( 842, 595, PDF, pdfPage2Filename);
        
        pdfPage2.beginDraw();
        
        // SHOPPING LIST
        Table table = new Table(14,6, 500);
        table.setFontSize(7);
        table.rowHeight = 11;
        
        String[] headers = { "phase / part", "material", "dimensions", "quantity", "general cost", "price estimation in €"};
        String[] row0 = { "", "", "", "", "", "" }; 
        String[] row1 = { "FLOOR CONSTRUCTION", "", "", "", "", "" }; 
        String[] row2 = { "    beams",  "pine wood" ,"44 x 145 mm", model.stats.construction.get("floorbeams total (m)") + " m", model.stats.COST_FLOORBEAMS + " € / m", str( model.stats.economy.get("cost floorbeams")) };
        String[] row3 = { "    decking",  "OSB2 board" ,"18 mm",  model.stats.usage.get("gross area") + " m2", model.stats.COST_FLOORPANEL + " € / m2", str( model.stats.economy.get("cost floor deck"))};
        String[] row4 = { "MAIN CONSTRUCTION",  "" ,"",  "", ""};
        String[] row5 = { "    wall and roofpanels",  "OSB3 board/plywood", "18 mm" , model.stats.construction.get("total panel area (m2)") + " m2",  model.stats.COST_PANEL + " € / m2" , str( model.stats.economy.get("cost panels")) };
        String[] row6 = { "    vertical / diagonals",  "pine wood", "50 x 50 + 50x100 mm" , model.stats.construction.get("total portal length (m)") + " m2",  model.stats.COST_VERTICALPROFILE + " € / m" , str( model.stats.economy.get("cost verticals"))};
        String[] row7 = { "FINISH",  "" ,"",  "", "", ""};
        String[] row8 = { "    waterproofing",  "watertight vapour-releasing layer", " " , model.stats.construction.get("total panel area (m2)") + " m2",  model.stats.COST_WATERPROOFING + " € / m2" , str( model.stats.economy.get("cost waterproofing"))};
        String[] row9 = { "    facade",  "treated wood boards", " " , model.stats.construction.get("total panel area (m2)") + " m2",  model.stats.COST_FACADE + " € / m2" , str( model.stats.economy.get("cost facade"))};
        String[] row10 = { "",  "" ,"",  "", "", ""};
        
        table.setRow(0, headers);
        table.setRow(1, row0);
        table.setRow(2, row1);
        table.setRow(3, row2);
        table.setRow(4, row3);
        table.setRow(5, row4);
        table.setRow(6, row5);
        table.setRow(7, row6);
        table.setRow(8, row7);
        table.setRow(9, row8);
        table.setRow(10, row9);
        table.setRow(11, row10);
        
        String[] row11 = { "", "", "", "TOTAL MATERIAL COST", "", str ( table.calculateColumnSum(5)) }; 
        table.setRow(12, row11);
        
        String[] row12 = { "", "", "", "MATERIAL COST PER AREA M2", "",  str (  float (table.data[12][5]) /  model.stats.usage.get("gross area")) };
        table.setRow(13, row12);
        
        table.setTitle("Materials shopping list");
        table.setPosition(30,300);
        table.drawOn(pdfPage2);
        
        // TOOLS
        PShape tools;
        tools = loadShape("tools.svg");
        pdfPage2.shape(tools);
        
        // ITS YOURS
        PShape yours;
        yours = loadShape("yours.svg");
        pdfPage2.shape(yours);
          
        pdfPage2.pushStyle();
        pdfPage2.fill(0xFF000000);
        PFont font = createFont("DIN-Regular-9.vlw", 8);
        //pdfPage2.textFont(font, 8); 
        //pdfPage2.text("Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum", 190, 170, 300, 600);
        //pdfPage2.popStyle();
        
        // PAGE TITLE
        drawPageTitle("2. PREPARATION", 20, "LEFT", "BOTTOM", pdfPage2);
        
        // FINISH PAGE 2 DRAWING
        pdfPage2.endDraw(); 
        pdfPage2.dispose();
        
        /*************************************************************/
        /*
        /*  PAGE 3: Floorconstruction
        /*
        /*
        /*************************************************************/
        
        String pdfPage3Filename = "manual_page3.pdf";
        
        PGraphics pdfPage3 = createGraphics( 842, 595, PDF, pdfPage3Filename);
        
        pdfPage3.beginDraw();
        
        plan.drawFloorConstructionOffset(0, 0 , pdfPage3);
        
        
        
         // CREATE TABLE
            Table floorTable = new Table(100,5,400);
            
            float angle1 = ((Vec3D) model.zzPointsLeft.get(1)).sub( (Vec3D) model.zzPointsLeft.get(0) ).getNormalized().getAbs().angleBetween(new Vec3D(0,1,0)); // * 180.0/PI;
            float angle2 = ((Vec3D) model.zzPointsLeft.get(2)).sub( (Vec3D) model.zzPointsLeft.get(1) ).getNormalized().getAbs().angleBetween(new Vec3D(0,1,0)); // * 180.0/PI;
            
            float sideDistance1 =  int ( ((Vec3D) model.zzPointsLeft.get(0)).distanceTo( (Vec3D) model.zzPointsLeft.get(1)));
            float sideDistance2 =  int ( ((Vec3D) model.zzPointsLeft.get(2)).distanceTo( (Vec3D) model.zzPointsLeft.get(1)));
            
            float sideOffset1 = BEAM_WIDTH / cos(angle1);
            float sideOffset2 = BEAM_WIDTH / cos(angle2);
            
            // with inset
            float sideLength1 =  sideDistance1 - sideOffset1;
            float sideLength2 =  sideDistance2 - sideOffset2;
            
            float inset1 = tan(angle1) * BEAM_WIDTH;
            float inset2 = tan(angle2) * BEAM_WIDTH;
            
            // horizontals 
            float horizontalWidth1 = ((Vec3D) model.zzPointsLeft.get(1)).x - ((Vec3D) model.zzPointsLeft.get(0)).x - 2 * BEAM_WIDTH;
            float horizontalWidth2 = ((Vec3D) model.zzPointsLeft.get(2)).x - ((Vec3D) model.zzPointsLeft.get(1)).x - 2 * BEAM_WIDTH; 
                    
            String[] floorRow0 = { "part", "material", "dimensions in mm", "length in cm", "inset/outset in mm"};
            String[] floorRow1 = { "", "", "", "", ""};
            String[] floorRow2 = { "sides", "pine wood", "44x145", "", ""};
            String[] floorRow3 = { "   side 1", "", "", str ( round (sideLength1 * 10.0) / 10.0 ) , str ( round (sideOffset1) )};
            String[] floorRow4 = { "   side 2", "", "", str ( round ( sideLength2 * 10.0) / 10.0) , str ( round (sideOffset2) )};
            String[] floorRow5 = { "horizontals", "pine wood", "44x145", "", ""};
            String[] floorRow6 = { "   horizontal 1", "", "", str ( round ( horizontalWidth1 * 10.0) / 10.0)  , ""};
            String[] floorRow7 = { "   horizontal 2", "", "", str ( round ( horizontalWidth2 * 10.0) / 10.0)  , ""};
            String[] floorRow8 = { "beams", "pine wood", "44x145", "", ""};
            
            // generate beams (if different)
            
            int prevBeamLengthEven = 0;
            int prevBeamLengthUneven = 0;
            
            for(int b = 0; b < model.zzPointsLeft.size(); b++)
            {
              int beamLength = int ( ((Vec3D) model.zzPointsLeft.get(b)).distanceTo( (Vec3D) model.zzPointsRight.get(b)));
              
              if(beamLength != prevBeamLengthEven && beamLength != prevBeamLengthUneven)
              {
                  if(b % 2 == 0)
                  {
                    // even
                    String[] row = { "   beam " + b, "" , "", str ( beamLength ), str ( round ( inset1 * 10.0 )) + " / " + str ( round ( inset2 * 10.0 ))};
                    floorTable.setRow(9+b, row);
                    prevBeamLengthEven = beamLength;
                  }
                  else 
                  {
                    // uneven  
                    String[] row = { "   beam " + b, "", "", str ( beamLength ), str ( round ( inset1 * 10.0 )) + " / " + str ( round ( inset2 * 10.0 ))};
                    floorTable.setRow(9+b, row);
                    prevBeamLengthUneven = beamLength;
                  }
              } 
            }        
           
        floorTable.setRow(0, floorRow0);
        floorTable.setRow(1, floorRow1);
        floorTable.setRow(2, floorRow2);
        floorTable.setRow(3, floorRow3); 
        floorTable.setRow(4, floorRow4); 
        floorTable.setRow(5, floorRow5); 
        floorTable.setRow(6, floorRow6);
        floorTable.setRow(7, floorRow7);
        floorTable.setRow(8, floorRow8);  
        
        floorTable.setPosition(30,60);
        floorTable.rowHeight = 9;   
        floorTable.setTitle("Floorconstruction dimensions");
        floorTable.setFontSize(7); 
        floorTable.drawOn(pdfPage3);
        
        drawPageTitle("3. FLOORCONSTRUCTION", 20, "LEFT", "BOTTOM", pdfPage3);
        
        // EXPLANATION
        PShape floor;
        floor = loadShape("floorconstruction.svg");
        pdfPage3.shape(floor);
        
        // FINISH PAGE 3 DRAWING
        pdfPage3.endDraw(); 
        pdfPage3.dispose();
        
        /************************************************************************/
        /*
        /*    PAGE 4: panel plan
        /*
        /************************************************************************/
        
        String pdfPage4Filename = "manual_page4.pdf";
        
        PGraphics pdfPage4 = createGraphics( 842, 595, PDF, pdfPage4Filename);
        
        pdfPage4.beginDraw();
        
        float panelThickness = DIY_PANEL_THICKNESS;
        float drawScale = 0.5;
        
        // DRAW PANEL PLAN
        float rowPosition = LAYOUTOFFSET_Y; // draw position 
        rowPosition += printPanelCollection(model.panelsWallLeft, pdfPage4, LAYOUTOFFSET_X, rowPosition, panelThickness, drawScale) + YMARGIN; // functions returns height of drawn model
        rowPosition += printPanelCollection(model.panelsRoofLeft, pdfPage4, LAYOUTOFFSET_X, rowPosition, panelThickness, drawScale) + YMARGIN;
        rowPosition += printPanelCollection(model.panelsRoofRight, pdfPage4, LAYOUTOFFSET_X, rowPosition, panelThickness, drawScale) + YMARGIN;
        rowPosition += printPanelCollection(model.panelsWallRight, pdfPage4, LAYOUTOFFSET_X, rowPosition, panelThickness, drawScale) + YMARGIN;
        
        // EXPLANATION
        PShape cutting;
        cutting = loadShape("cutting.svg");
        pdfPage4.shape(cutting);
        
        // SET TITLE
        drawPageTitle("4. PANELS", 20, "LEFT", "BOTTOM", pdfPage4);
        
        // FINISH PAGE 4 DRAWING
        pdfPage4.endDraw(); 
        pdfPage4.dispose();
        
                
        /************************************************************************/
        /*
        /*    PAGE 5: build up
        /*
        /************************************************************************/
        
        String pdfPage5Filename = "manual_page5.pdf";
        
        PGraphics pdfPage5 = createGraphics( 842, 595, PDF, pdfPage5Filename);
        
        pdfPage5.beginDraw();
        
        // EXPLANATION
        PShape buildup;
        buildup = loadShape("buildup.svg");
        pdfPage5.shape(buildup);
        
        // SET TITLE
        drawPageTitle("5. BUILD UP", 20, "LEFT", "BOTTOM", pdfPage5);
        
        // FINISH PAGE 5 DRAWING
        pdfPage5.endDraw(); 
        pdfPage5.dispose();
        
        /************************************************************************/
        /*
        /*    PAGE 6: finish
        /*
        /************************************************************************/
        
        String pdfPage6Filename = "manual_page6.pdf";
        
        PGraphics pdfPage6 = createGraphics( 842, 595, PDF, pdfPage6Filename);
        
        pdfPage6.beginDraw();
        
        // EXPLANATION
        PShape finish;
        finish = loadShape("finish.svg");
        pdfPage6.shape(finish);
        
        // SET TITLE
        drawPageTitle("6. FINISHES", 20, "LEFT", "BOTTOM", pdfPage6);
        
        // FINISH PAGE 6 DRAWING
        pdfPage6.endDraw(); 
        pdfPage6.dispose();
        
         /************************************************************************/
        /*
        /*    PAGE X: private calculations
        /*
        /************************************************************************/
        
        String pdfPageCalcFilename = "model_calc.pdf";
        
        PGraphics pdfPageCalc = createGraphics( 842, 595, PDF, pdfPageCalcFilename);
        
        pdfPageCalc.beginDraw();
        
        // SET TITLE
        drawPageTitle("COST CALCULATION", 20, "LEFT", "BOTTOM", pdfPageCalc);
        
        // TABLE RC

        Table tableRC = new Table(17,6, 700);
        tableRC.setFontSize(6);
        tableRC.rowHeight = 10;
        
        //float costRCSum = model.stats.calculateAreaGross() * model.stats.COST_RC_FLOORPANEL + model.getNumPanels() * model.stats.COST_RC_FLOORPANEL_MODS + model.stats.calculateTotalPanelArea() * model.stats.COST_RC_PANEL + model.getNumPanels() * model.stats.COST_RC_PANEL_MODS + model.stats.calculateTotalPanelArea() * model.stats.COST_WATERPROOFING + model.stats.calculateTotalPanelArea() * model.stats.COST_FACADE_TOTAL;
        
        String[] headersRC = { "partner / phase", "part", "specifics", "quantity", "price per quantity", "price estimation in €" };
        String[] row0RC = { "", "", "", "", "", "" }; 
        String[] row1RC = { "FLOOR CONSTRUCTION",  "" ,"",  "", "", ""};
        String[] row2RC = { "   RC",  "floor segments" ,"OSB 18 + EPS 100 + SP 10",  model.stats.calculateAreaGross() + " m2", model.stats.COST_RC_FLOORPANEL + " € / m2", str(  model.stats.calculateAreaGross() * model.stats.COST_RC_FLOORPANEL)  };
        String[] row3RC = { "   HH", "floor segments modifications", "producing zigzag", model.getNumPanels() / 4 + " floorsegments", str ( model.stats.COST_RC_FLOORPANEL_MODS) , str(  model.getNumPanels() / 4 * model.stats.COST_RC_FLOORPANEL_MODS) }; 
        String[] row4RC = { "MAIN CONSTRUCTION",  "" ,"",  "", "", "" };
        String[] row5RC = { "   RC",  "wall and roof panels" ,"GPS 10 + EPS 70 + SP 10",  model.stats.calculateTotalPanelArea() + " m2", model.stats.COST_RC_PANEL + " € / m2", str(  model.stats.calculateTotalPanelArea() * model.stats.COST_RC_PANEL)  };
        String[] row6RC = { "   HH", "panel modifications", "producing zigzag", str (model.getNumPanels()) + " panels", str ( model.stats.COST_RC_PANEL_MODS) , str(  model.getNumPanels() * model.stats.COST_RC_PANEL_MODS) }; 
        String[] row7RC = { "   HH",  "waterproof layer", " " , model.stats.calculateTotalPanelArea() + " m2",  model.stats.COST_WATERPROOFING + " € / m2" , str( model.stats.calculateTotalPanelArea() * model.stats.COST_WATERPROOFING)};
        String[] row8RC = { "   HH / AP",  "facade", "material + prefabrication" , model.stats.calculateTotalPanelArea() + " m2",  model.stats.COST_FACADE_TOTAL + " € / m2" , str( model.stats.calculateTotalPanelArea() * model.stats.COST_FACADE_TOTAL)};
        String[] row9RC = { "   HH / AP",  "basic entrance", " " , "1" , str ( model.stats.COST_ENTRANCE ), str( model.stats.COST_ENTRANCE )};
        String[] row10RC = { "",  "" ,"",  "", "", ""};
        
        tableRC.setRow(0, headersRC);
        tableRC.setRow(1, row0RC);
        tableRC.setRow(2, row1RC);
        tableRC.setRow(3, row2RC);
        tableRC.setRow(4, row3RC);
        tableRC.setRow(5, row4RC);
        tableRC.setRow(6, row5RC);
        tableRC.setRow(7, row6RC);
        tableRC.setRow(8, row7RC);
        tableRC.setRow(9, row8RC);
        tableRC.setRow(10, row9RC);
        tableRC.setRow(11, row10RC);
        
        String[] row11RC = { "", "", "", "BUILDING KIT TOTAL [EXCL. BTW]", "", str ( tableRC.calculateColumnSum(5)) }; 
        tableRC.setRow(12, row11RC);
        
        String[] row12RC = { "", "GROSS FLOOR AREA", model.stats.usage.get("gross area") + " m2" , "COST PER AREA M2 [EXCL.BTW]", "",  str (  float (tableRC.data[12][5]) /  model.stats.usage.get("gross area") ) };
        tableRC.setRow(13, row12RC);
        
        
        tableRC.setTitle("RC PANEL CONSTRUCTION COST");
        tableRC.setPosition(30,30);
        tableRC.drawOn(pdfPageCalc);
        
          // TABLE POIROT

        Table tableP = new Table(17,6, 700);
        tableP.setFontSize(6);
        tableP.rowHeight = 10;
        
        String[] headersP = { "partner / phase", "part", "specifics", "quantity", "price per quantity", "price estimation in €" };
        String[] row0P = { "", "", "", "", "", "" }; 
        String[] row1P = { "FLOOR CONSTRUCTION",  "" ,"",  "", "", ""};
        String[] row2P = { "   HH",  "beams materiaal" ,"50x100",  model.stats.calculateTotalFloorBeamLength() + " m", model.stats.COST_POIROT_FLOORBEAMS + " € / m", str( model.stats.calculateTotalFloorBeamLength() * model.stats.COST_POIROT_FLOORBEAMS )  };
        String[] row3P = { "   HH", "decking + insulation", "OSB 18 + EPS 100 + SP10", model.stats.calculateAreaGross() + " m2", model.stats.COST_POIROT_FLOOR_MAT + " € / m" , str(  model.stats.calculateAreaGross() * model.stats.COST_POIROT_FLOOR_MAT) }; 
        String[] row4P = { "   HH", "segment labor", "saw", model.getNumPanels() / 4 + " floorsegments", str ( model.stats.COST_POIROT_FLOOR_LAB) , str(  model.getNumPanels() / 4 * model.stats.COST_POIROT_FLOOR_LAB) }; 
        String[] row5P = { "MAIN CONSTRUCTION",  "" ,"",  "", "", "" };
        String[] row6P = { "   HH",  "wall and roof panels" ,"OSB 18 + EPS 50",  model.stats.calculateTotalPanelArea() + " m2", model.stats.COST_POIROT_PANEL_MAT + " € / m2", str(  model.stats.calculateTotalPanelArea() * model.stats.COST_POIROT_PANEL_MAT)  };
        String[] row7P = { "   HH", "panel labor", " ", str (model.getNumPanels()) + " panels", str ( model.stats.COST_POIROT_PANEL_LAB) , str(  model.getNumPanels() * model.stats.COST_POIROT_PANEL_LAB) }; 
        String[] row8P = { "   HH",  "waterproof layer", " " , model.stats.calculateTotalPanelArea() + " m2",  model.stats.COST_WATERPROOFING + " € / m2" , str( model.stats.calculateTotalPanelArea() * model.stats.COST_WATERPROOFING)};
        String[] row9P = { "   HH / AP",  "facade", "material + prefabrication" , model.stats.calculateTotalPanelArea() + " m2",  model.stats.COST_FACADE_TOTAL + " € / m2" , str( model.stats.calculateTotalPanelArea() * model.stats.COST_FACADE_TOTAL)};
        String[] row10P = { "   HH / AP",  "basic entrance", " " , "1" , str ( model.stats.COST_ENTRANCE ), str( model.stats.COST_ENTRANCE )};
        String[] row11P = { "",  "" ,"",  "", "", ""};
        
        tableP.setRow(0, headersP);
        tableP.setRow(1, row0P);
        tableP.setRow(2, row1P);
        tableP.setRow(3, row2P);
        tableP.setRow(4, row3P);
        tableP.setRow(5, row4P);
        tableP.setRow(6, row5P);
        tableP.setRow(7, row6P);
        tableP.setRow(8, row7P);
        tableP.setRow(9, row8P);
        tableP.setRow(10, row9P);
        tableP.setRow(11, row10P);
        tableP.setRow(12, row11P);
        
        String[] row12P = { "", "", "", "BUILDING KIT TOTAL [EXCL. BTW]", "", str ( tableP.calculateColumnSum(5)) }; 
        tableP.setRow(13, row12P);
        
        String[] row13P = { "", "GROSS FLOOR AREA", model.stats.usage.get("gross area") + " m2" , "COST PER AREA M2 [EXCL.BTW]", "",  str (  float (tableP.data[13][5]) /  model.stats.usage.get("gross area") ) };
        tableP.setRow(14, row13P);
        
        
        tableP.setTitle("POIROT PANEL CONSTRUCTION COST");
        tableP.setPosition(30,300);
        tableP.drawOn(pdfPageCalc);


        
        // FINISH PAGE 6 DRAWING
        pdfPageCalc.endDraw(); 
        pdfPageCalc.dispose();
   }
   
   public float printPanelCollection(ArrayList panels, PGraphics canvas, float rowx, float rowy, float panelThickness, float drawScale)
   {  
            // draw specific collection (wallleft, roofleft etc) on canvas
                  
            geomPanel panel = null;
            geomPanel lastPanel = null;
            geomPanel firstPanel = null;
            geomPanel prevPanel = null;
            
            panelFlat prevPanelFlat = null;    
            panelFlat firstPanelScaled = null;
            panelFlat lastPanelScaled = null;
                
            panelFlat flatPanelDrawn = null;
                
            boolean mirror = false;
            
            float x = 0;
          
            for(int p = 0; p < panels.size(); p++) 
            {
                    panel = (geomPanel) panels.get(p);
                      
                    // MIRROR
                    
                    if(panel.type == "WALLRIGHT" || panel.type == "ROOFRIGHT")
                    {
                      mirror = true;
                    }
                    else {
                      mirror = false;
                    }
                    
                    flatPanelDrawn = panel.layOutAndDrawOn(rowx + x, rowy, mirror, prevPanelFlat, canvas, panelThickness, drawScale);  
                    
                    // LET OP: PAK WIDTH VAN panelFLAT, niet origineel TE DOEN
                     x += flatPanelDrawn.panelWidth + (panelThickness * 2);
                     
                    // COLUMS AND ROW RELATIONS
                    if(p != 0){
                       prevPanel = (geomPanel) panels.get(p-1);
                    }
                    if(p == 0)
                    {
                      firstPanel = panel; 
                      firstPanelScaled = flatPanelDrawn;
                    }
                    
                    if(p == panels.size() - 1)
                    {
                      lastPanel = panel;
                      lastPanelScaled = flatPanelDrawn;
                    }
                    // track previous panel
                    prevPanelFlat = flatPanelDrawn;
            }
            
            
            // calculate row height as return value
            float rowHeight; 
                
            if(firstPanel.panelHeight > lastPanel.panelHeight)
            {
                    rowHeight = firstPanelScaled.panelHeight; // TODO: MARGIN
            }
            else 
            {
                    rowHeight = lastPanelScaled.panelHeight; // TO DO: MARGIN
            }
            
            return rowHeight;
    }  
    
   public void outputScreen(String f)
   {
      saveFrame(f); 
   }
   
   public void drawScalebar(int x, int y, int s, PGraphics canvas)
   {
       // SCALE 1:S
       // 1:100 => 1cm => 1 mm (DRAWING_SCALE)
       float scale = 100.0 / s;
       
       
       canvas.pushStyle();
       canvas.strokeWeight(1);
       canvas.fill(0xFF000000);
       canvas.line(x,y, x, y + 10);
       canvas.line(x,y + 10, x + 100 * scale * DRAWING_SCALE_A4, y + 10);
       canvas.line( x+ 100 * scale * DRAWING_SCALE_A4 ,y,  x+100 * DRAWING_SCALE_A4 * scale, y + 10);
       PFont font = createFont("DIN-Regular-10.vlw", 10);
       canvas.textAlign(CENTER, CENTER);
       canvas.textFont(font, 10); 
       canvas.text( "1m", x + 100 * scale * DRAWING_SCALE_A4 / 2, y);
       canvas.popStyle();
   }
   
   public void drawPageTitle(String t, int size, String halign, String valign, PGraphics canvas)
   {
       int PAGEMARGIN = 20;
     
       int w = canvas.width;
       int h = canvas.height;
        
       PFont font = createFont("DIN-Regular-30.vlw", size);
       canvas.textFont(font, size); 
       
       canvas.pushStyle();
       
       canvas.fill(0xFF6bd22a);
       
       int positionx = PAGEMARGIN;
       int positiony = PAGEMARGIN;
       
       if(halign == "LEFT")
       {
         positionx = PAGEMARGIN;
         canvas.textAlign(LEFT);
       }
       else {
         positionx = w - PAGEMARGIN;         
         canvas.textAlign(RIGHT);
       }
        
       if(valign == "UP")
       {
         positiony = PAGEMARGIN;
         if(halign == "LEFT")
           canvas.textAlign(LEFT, UP);
         else
           canvas.textAlign(RIGHT, UP);
       }
       else {
         positiony = h - PAGEMARGIN;

         if(halign == "LEFT")
           canvas.textAlign(LEFT, BOTTOM);
         else
           canvas.textAlign(RIGHT, BOTTOM);         
       }
         
       canvas.text(t, positionx, positiony);

       canvas.popStyle();
   }
}
