FloatTable data;
float dataMin, dataMax;

int numCoordinates;
float coordinateBarWidth = 2;
float [] coordinateLocs;

int currentColumn = 0;
int columnCount;
int rowCount;

float plotX1, plotY1;
float plotX2, plotY2;
float labelX, labelY;

float paramMin, paramMax;

PFont plotFont;

void setup(){
  size(720,405);
  data = new FloatTable("cars.tsv");
  columnCount = data.getColumnCount();
  rowCount = data.getRowCount();
  numCoordinates = columnCount;
  coordinateLocs = new float[numCoordinates];

  // corners:
  plotX1 = 120;
  plotX2 = width-80;
  labelX = 50;
  plotY1 = 60;
  plotY2 = height-70;
  labelY = height-25;
  
  plotFont = createFont("Verdana",24);

  dataMin = data.getColumnMin(currentColumn);
  dataMax = data.getColumnMax(currentColumn);
}

void draw(){

  background(224);
  
  // show plot area as a white box
  fill(255);
  rectMode(CORNERS);
  noStroke();
  rect(plotX1,plotY1, plotX2,plotY2);

  // draw coordinate bars
  drawCoordinateBars();
  
  stroke(#5679C1);
  strokeWeight(4);
  drawDataPoints(currentColumn);
  drawTitle();
}

void drawCoordinateBars(){
  fill(#5679C1);
  rectMode(CORNERS);
  noStroke();

  for(int c=0; c<numCoordinates;c++){
    float xloc = map(c,0,numCoordinates,plotX1,plotX2);
    coordinateLocs[c] = xloc;
    float xstart = xloc-coordinateBarWidth/2;
    float xend = xloc+coordinateBarWidth/2;
    rect(xstart,plotY1, xend,plotY2);
  }
}

void drawTitle(){
  fill(0);
  textFont(plotFont);
  textAlign(CENTER);
  String title = data.getColumnName(currentColumn);
  text(title, (plotX1+plotX2)/2, plotY1-13);
}

void drawDataPoints(int col){
  for(int row=0; row<rowCount; ++row){
    if(data.isValid(row,col)){
      float value = data.getFloat(row,col);
      float x = map(row, 0, rowCount, plotX1,plotX2);
      float y = map(value, dataMin, dataMax, plotY2, plotY1);
      point(x,y);
    }
  }
}


void keyPressed(){
  
  int oldColumn = currentColumn;
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
  if(currentColumn != oldColumn){
    dataMin = data.getColumnMin(currentColumn);
    dataMax = data.getColumnMax(currentColumn);
  }
}
