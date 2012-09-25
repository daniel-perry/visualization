FloatTable data;
float dataMin, dataMax;

float plotX1, plotY1;
float plotX2, plotY2;
float labelX, labelY;

int currentColumn = 0;
int columnCount;
int rowCount;

int yearMin, yearMax;
int [] years;

PFont plotFont;

int yearInterval = 10;
int volumeInterval = 10;
int volumeIntervalMinor = 5;

void setup(){
  size(720,405);
  data = new FloatTable("milk-tea-coffee.tsv");
  columnCount = data.getColumnCount();
  rowCount = data.getRowCount();

  years = int(data.getRowNames());
  yearMin = years[0];
  yearMax = years[years.length-1];

  dataMin = 0;
  dataMax = ceil(data.getTableMax()/volumeInterval)*volumeInterval;
  
  // corners:
  plotX1 = 120;
  plotX2 = width-80;
  labelX = 50;
  plotY1 = 60;
  plotY2 = height-70;
  labelY = height-25;
  
  //plotFont = createFont("SansSerif",20);
  plotFont = createFont("Verdana",20);
  textFont(plotFont);
  
  smooth();
}

void draw(){
  background(224);
  
  // show plot area as a white box
  fill(255);
  rectMode(CORNERS);
  noStroke();
  rect(plotX1,plotY1, plotX2,plotY2);
 
  // Draw the title of the current plot.
  drawTitle();
  drawAxisLabels();
    
  strokeWeight(5);
  // Draw data from the first column
  stroke(#5679C1);
  drawDataPoints(currentColumn);
  
  // Draw axis labels
  drawYearLabels();
  drawVolumeLabels();
}

void drawTitle(){
  fill(0);
  textSize(20);
  textAlign(LEFT);
  String title = data.getColumnName(currentColumn);
  text(title, plotX1, plotY1-10);
}

void drawAxisLabels(){
  fill(0);
  textSize(13);
  textLeading(15);
  
  textAlign(CENTER,CENTER);
  text("Gallons\nconsumed\nper capita", labelX, (plotY1+plotY2)/2);
  textAlign(CENTER);
  text("Year", (plotX1+plotX2)/2, labelY);
}

void drawDataPoints(int col){
  for(int row=0; row<rowCount; ++row){
    if(data.isValid(row,col)){
      float value = data.getFloat(row,col);
      float x = map(years[row], yearMin, yearMax, plotX1,plotX2);
      float y = map(value, dataMin, dataMax, plotY2, plotY1);
      point(x,y);
    }
  }
}

void drawYearLabels(){
  fill(0);
  textSize(10);
  textAlign(CENTER,TOP);
  
  // use thin, gray lines to draw grid
  stroke(224);
  strokeWeight(1);
  
  for(int row=0; row<rowCount; row++) {
    if( years[row] % yearInterval == 0) {
      float x=map(years[row], yearMin, yearMax, plotX1, plotX2);
      text(years[row],x,plotY2+10);
      line(x, plotY1, x, plotY2);
    }
  }
}

void drawVolumeLabels(){  
  fill(0);
  textSize(10);
  stroke(128);
  strokeWeight(1);
  
  for(float v=dataMin; v<=dataMax; v+=volumeIntervalMinor){
    if(v%volumeIntervalMinor == 0){
      float y = map(v, dataMin, dataMax, plotY2, plotY1);
      if(v%volumeInterval == 0){
        if(v==dataMin){
          textAlign(RIGHT,BOTTOM);
        }else if(v==dataMax){
          textAlign(RIGHT,TOP);
        }else{
          textAlign(RIGHT,CENTER);
        }      
        text(floor(v), plotX1-10, y);
        line(plotX1-4, y, plotX1, y); // major tick
      } else {
        line(plotX1-2, y, plotX1, y); // minor tick
      }
    }
  }
}

void keyPressed(){
  if( key == '[' ){
    --currentColumn;
    if( currentColumn < 0 ){
      currentColumn = columnCount - 1;
    }
  } else if( key == ']' ){
    ++currentColumn;
    if( currentColumn == columnCount ){
      currentColumn = 0;
    }
  }
}

