FloatTable data;
float []dataMin;
float [] dataMax;

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
int [] paramOrdering;

PFont plotFont;

void setup(){
  size(920,605);
  data = new FloatTable("cars.tsv");
  columnCount = data.getColumnCount();
  rowCount = data.getRowCount();
  numCoordinates = columnCount;
  coordinateLocs = new float[numCoordinates];

  paramOrdering = new int[numCoordinates];
  for(int i=0; i<numCoordinates; ++i){
    paramOrdering[i] = i; // default ordering is 0 to N-1
  }

  // corners:
  plotX1 = 120;
  plotX2 = width-80;
  labelX = 50;
  plotY1 = 60;
  plotY2 = height-70;
  labelY = height-25;
  
  plotFont = createFont("Verdana",24);

  dataMin = new float[columnCount];
  dataMax = new float[columnCount];
  for(int col=0; col<columnCount; ++col){
    dataMin[col] = data.getColumnMin(col);
    dataMax[col] = data.getColumnMax(col);
  }
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
  //drawDataPoints(currentColumn);
  drawLines();
  drawTitles();
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

void drawTitles(){
  fill(0);
  textFont(plotFont);
  textAlign(CENTER);
  for(int c=0; c<columnCount; ++c){
    String title = data.getColumnName(currentColumn);
    text(title, coordinateLocs[c], plotY1-13);
  }
}

void drawLines(){
  stroke(#56C1C1);
  strokeWeight(1);
  noFill();
  for(int row=0; row<rowCount; ++row){
    //stroke(colors[color_i++]);
    beginShape();
    for(int col=0; col<columnCount; ++col){
      if(data.isValid(row,col)){
        float value = data.getFloat(row,col);
        float x = coordinateLocs[col]; //map(row, 0, rowCount, plotX1,plotX2);
        float y = map(value, dataMin[col], dataMax[col], plotY2, plotY1);
        vertex(x,y);
      }
    }
    endShape();
  }
}

void drawDataPoints(int col){
  for(int row=0; row<rowCount; ++row){
    if(data.isValid(row,col)){
      float value = data.getFloat(row,col);
      float x = map(row, 0, rowCount, plotX1,plotX2);
      float y = map(value, dataMin[currentColumn], dataMax[currentColumn], plotY2, plotY1);
      point(x,y);
    }
  }
}

void changeOrdering(int amt){
  int tmp;
  int target_i;
  int [] neworder = new int[numCoordinates];
  for(int i=0; i<numCoordinates; ++i){
    if( i + amt >= numCoordinates ){
      target_i = (i+amt) - numCoordinates;
    }else if(i + amt < 0){
      target_i = numCoordinates + (i+amt);
    }else{
      target_i = i+amt;
    }
    neworder[target_i] = paramOrdering[i];
  }
  paramOrdering = neworder;
}

void keyPressed(){
  
  int oldColumn = currentColumn;
  if( key == '[' ){
    --currentColumn;
    if( currentColumn < 0 ){
      currentColumn = columnCount - 1;
    }
    changeOrdering(-1);
  } else if( key == ']' ){
    ++currentColumn;
    if( currentColumn == columnCount ){
      currentColumn = 0;
    }
    changeOrdering(1);
  }
}
