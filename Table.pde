public class Table
{  
  // SETTINGS
  int LINE_DASH = 5;
  color TEXTCOLOR = 0xFF000000;
  color LINECOLOR = 0xFFAAAAAA;
  color TITLECOLOR = 0xFF6bd22a;
  String LINETYPE = "NORMAL";
  
  public String[][] data;
  
  PVector position = new PVector(0,0);
  int tableWidth;
  int tableHeight;
  
  String title = "";
  int fontSize = 9;
  int titleFontSize = 12;
  int columnWidth;
  int rowHeight = 20;
  int rowMargin = 5;
  
  color textColor = TEXTCOLOR;
  color lineColor = LINECOLOR;
  String lineType = LINETYPE;
  color titleColor = TITLECOLOR;
  
  PGraphics activeCanvas = null;
  
  public Table(int r, int c, int w)
  {
     data = new String[r][c];
     tableWidth = w;
     reset();
  }
  public void setValue(int r, int c, String v)
  {
     // protect against wrong indices
     if(r > data.length || c > data[0].length)
     {
         println("=> Table:setValue - wrong indices");
         return;
     }
     
     // set value
     data[r][c] = v;
  }
  
  public void reset()
  {
     for(int r = 0; r < data.length; r++)
     {
        for(int c = 0; c < data[0].length; c++)
        {
            data[r][c] = "NULL"; 
        }
     } 
  }
  
  public void setRow(int nr, String[] values)
  {  
     //arrayCopy(data[nr], values);
     
     for(int c = 0; c < values.length; c++)
     {
        data[nr][c] = values[c]; 
     }
  }
  
  public void setColumn(int nr, String[] values)
  {
     for(int r = 0; r < data.length; r++)
     {
        data[r][nr] = values[r]; 
     }
  }
  public void calculateColumnWidth()
  {
     columnWidth = tableWidth / data[0].length; 
  }
  
  public void setPosition(int x,int y)
  {
     // set position
      position.x = x;
      position.y = y;
  }
  public void drawOn(PGraphics canvas)
  {
     // draw on canvas 
     activeCanvas = canvas;
     
     boolean primary = canvas.is3D(); // when 3d it is the primary screen 
     
      if(!primary)
        canvas.beginDraw();
        
      // real draw routine
      calculateColumnWidth();
      
      canvas.pushMatrix();
      canvas.translate(position.x, position.y);
      canvas.pushStyle();
      
      // title
      canvas.fill(titleColor);
      setFont(titleFontSize);
      
      if(title.length() > 0)
      {
          canvas.text(title, 0, 0);
      }
      
      canvas.fill(textColor);
      setFontSize(fontSize);
      
      // draw rows
      for(int r = 0; r < data.length; r++)
      {
         drawRow(r);
      }
      
      canvas.popStyle();
      canvas.popMatrix();
      
      if(!primary)
        canvas.endDraw();
  }
  public boolean isUnusedRow(int nr)
  {
     for(int c = 0; c < data[nr].length; c++)
     {
        println(data[nr][c]);
       
        if(data[nr][c] == "NULL")
          return true;
     }
     
     return false;
  }
  public void draw()
  {
      drawOn(g);
  }
  
  public void setFontSize(int s)
  {
      fontSize = s;
      setFont(s);
  }
  
  public void setFont(int s)
  {
      // direct without saving fontsize
      PFont font = createFont("DIN-Regular-9.vlw", s);
      
      if(activeCanvas != null)
      {
        activeCanvas.textFont(font, s);
      }
  }
  
  public void drawRow(int nr)
  {
      if(!isUnusedRow(nr))
      {  
    
        for(int c = 0; c < data[nr].length; c++)
        {
            // draw columns
            if(data[nr][c] != "NULL" && data[nr][c] != null)
            {
              activeCanvas.text(data[nr][c], columnWidth * c, (nr +1) * (rowHeight + rowMargin)); //, columnWidth, rowHeight*2);
            } 
        }
        // draw line
        activeCanvas.pushStyle();
        activeCanvas.stroke(lineColor);
        
        if(lineType == "DASHED")
          dashline(0, (nr + 1) * (rowHeight + rowMargin) + rowMargin, tableWidth, (nr + 1) * (rowHeight + rowMargin) + rowMargin, LINE_DASH, LINE_DASH, activeCanvas);
        else 
          activeCanvas.line( 0, (nr + 1) * (rowHeight + rowMargin) + rowMargin, tableWidth, (nr + 1) * (rowHeight + rowMargin) + rowMargin);
          
        activeCanvas.popStyle();
      }
  }
  
  void roundValues()
  {
      for(int r = 0; r < data.length; r++)
      {
         for(int c = 0; c < data[0].length; c++)
         { 
              data[r][c] = trimDecimals(data[r][c]) ;
         }
      }
  }
  void setTitle(String t)
  {
      title = t;
  }
  String trimDecimals(String str)
  {
      if(str.indexOf(".") != -1)
      {
           float num =  float (str);
           return str ( round(num));  
      }
      else {
          return str;
      }
  }
  
  float calculateColumnSum(int col)
  {
      float sum = 0;
    
      for(int r = 0; r < data.length; r++)
      {
            float num = float (data[r][col] );
            
            if(!Float.isNaN(num))
            {
                  println(num);
                  sum += num;
            }
      }
      
      return sum;
  } 
  
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
