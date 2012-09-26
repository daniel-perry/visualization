FloatTable data;
float dataMin, dataMax;

float plotX1, plotY1;
float plotX2, plotY2;
float labelX, labelY;

int currentColumn = 3;
int columnCount;
int rowCount;

int yearMin, yearMax;
int [] years;

PFont plotFont;
PFont axisFont;
PFont highlightFont;

int yearInterval = 10;
int volumeInterval = 10;
int volumeIntervalMinor = 5;

float barWidth = 4;
int displayMode = 4;

float[] tabLeft, tabRight;
float tabTop, tabBottom;
float tabPad = 10;

Integrator[] interpolators;
int [] colors = {#5679C1,#56C179,#C15679};

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

  interpolators = new Integrator[rowCount];
  for(int row=0; row<rowCount; row++){
    float initialValue = data.getFloat(row, 0);
    interpolators[row] = new Integrator(initialValue);
    //interpolators[row].attraction = 0.1; // set lower than default
  }
  
  // corners:
  plotX1 = 120;
  plotX2 = width-80;
  labelX = 50;
  plotY1 = 60;
  plotY2 = height-70;
  labelY = height-25;
  
  //plotFont = createFont("SansSerif",20);
  plotFont = createFont("Verdana",24);
  axisFont = createFont("Georgia",17);
  highlightFont = createFont("Georgia",10);
  
  smooth();
}

void draw(){
  background(224);

  for(int row=0; row<rowCount; row++)
  {
    interpolators[row].update();
  }
  
  // show plot area as a white box
  fill(255);
  rectMode(CORNERS);
  noStroke();
  rect(plotX1,plotY1, plotX2,plotY2);
 
  // Draw the title of the current plot.
  //drawTitle();
  drawTitleTabs();
  drawAxisLabels();
  // Draw axis labels
  drawVolumeLabels();

  if(displayMode == 1){ // points
    drawYearLabels();
    stroke(#5679C1);
    strokeWeight(4);
    drawDataPoints(currentColumn);
  } else if(displayMode == 2){ // connected dots
    drawYearLabels();
    stroke(#5679C1);
    strokeWeight(0.5);
    noFill();
    drawDataLine(currentColumn);
    strokeWeight(4);
    drawDataPoints(currentColumn);
  } else if (displayMode == 3){ // line chart
    drawYearLabels();
    stroke(#5679C1);
    strokeWeight(2);
    noFill();
    drawDataLine(currentColumn);
  } else if (displayMode == 4){ // filled chart
    noStroke();
    fill(colors[currentColumn]);
    drawDataArea(currentColumn);  
    drawYearLabels();
  } else if (displayMode == 5){ // bar chart
    noStroke();
    fill(#5679C1);
    drawDataBars(currentColumn);
    drawYearLabels();
  }

  stroke(#5679C1);
  strokeWeight(2);
  noFill();
  drawDataHighlight(currentColumn);  
}

void drawTitle(){
  fill(0);
  textFont(plotFont);
  textAlign(CENTER);
  String title = data.getColumnName(currentColumn);
  text(title, (plotX1+plotX2)/2, plotY1-13);
}

void drawTitleTabs() {
  rectMode(CORNERS);
  noStroke();
  textSize(20);
  textAlign(LEFT);
  
  if(tabLeft == null){
    tabLeft = new float[columnCount+1];
    tabRight = new float[columnCount+1];
  }
  
  float runningX = plotX1;
  tabTop = plotY1 - textAscent() - 15;
  tabBottom = plotY1;
  
  for(int col=0; col<columnCount; col++){
    String title = data.getColumnName(col);
    tabLeft[col] = runningX;
    float titleWidth = textWidth(title);
    tabRight[col] = tabLeft[col] + tabPad + titleWidth + tabPad;
    
    fill(col == currentColumn ? 255 : 224);
    rect(tabLeft[col], tabTop, tabRight[col], tabBottom);
    
    //fill(col == currentColumn ? 0 : 64);
    fill(colors[col]);
    text(title, runningX + tabPad, plotY1 - 10);
    
    runningX = tabRight[col];
  }
  // last tab:
  int lastTab = columnCount;
  String title = "All";
  tabLeft[lastTab] = runningX;
  float titleWidth = textWidth(title);
  tabRight[lastTab] = tabLeft[lastTab] + tabPad + titleWidth + tabPad;  
  fill(lastTab == currentColumn ? 255 : 224);
  rect(tabLeft[lastTab], tabTop, tabRight[lastTab], tabBottom);  
  fill(lastTab == currentColumn ? 0 : 64);
  text(title, runningX + tabPad, plotY1 - 10);    
}

void drawAxisLabels(){
  fill(0);
  textFont(axisFont);
  textLeading(15);

  pushMatrix();
  rotate(-PI/2);  
  textAlign(CENTER,CENTER);
  text("Gallons consumed per capita", -(plotY1+plotY2)/2, labelX);
  popMatrix();
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

void drawDataLine(int col){
  int endCol = col;
  if(col == columnCount){
    col = 0;
    endCol = columnCount - 1;
  }
  int color_i = 0;
  for(; col<=endCol; col++){
    stroke(colors[color_i++]);
    beginShape();
    for(int row=0; row<rowCount; ++row){
      if(data.isValid(row,col)){
        float value = data.getFloat(row,col);
        float x = map(years[row], yearMin, yearMax, plotX1,plotX2);
        float y = map(value, dataMin, dataMax, plotY2, plotY1);      
        curveVertex(x,y);
        if((row==0) || (row==rowCount-1)){
          curveVertex(x,y); // doulbe curve points at start and stop
        }
      }
    }
    endShape();
  }
}

void drawDataArea(int col){
  beginShape();
  for(int row=0; row<rowCount; ++row){
    if(data.isValid(row,col)){
      //float value = data.getFloat(row,col);
      float value = interpolators[row].value();
      float x = map(years[row], yearMin, yearMax, plotX1,plotX2);
      float y = map(value, dataMin, dataMax, plotY2, plotY1);
      vertex(x,y);
    }
  }
  vertex(plotX2, plotY2);
  vertex(plotX1, plotY2);
  endShape(CLOSE);
}

void drawDataBars(int col){
  noStroke();
  rectMode(CORNERS);

  for(int row=0; row<rowCount; ++row){
    if(data.isValid(row,col)){
      float value = data.getFloat(row,col);
      float x = map(years[row], yearMin, yearMax, plotX1,plotX2);
      float y = map(value, dataMin, dataMax, plotY2, plotY1);
      rect(x-barWidth/2, y, x+barWidth/2, plotY2);
    }
  }
}

void drawDataHighlight(int col){
  textFont(highlightFont);
  for(int row=0; row<rowCount; ++row){
    if(data.isValid(row,col)){
      float value = data.getFloat(row,col);
      float x = map(years[row], yearMin, yearMax, plotX1,plotX2);
      float y = map(value, dataMin, dataMax, plotY2, plotY1);
      if(dist(mouseX,mouseY, x,y) < 3){
        stroke(100,255,100);
        strokeWeight(10);
        point(x,y);
        fill(0);
        textSize(10);
        textAlign(CENTER);
        text(nf(value, 0, 2) + " (" + years[row] + ")", x, y-8);
      }
    }
  }
}

void drawYearLabels(){
  textSize(10);
  textAlign(CENTER,TOP);
  
  stroke(150);
  strokeWeight(1);
  
  for(int row=0; row<rowCount; row++) {
    if( years[row] % yearInterval == 0) {
      float x=map(years[row], yearMin, yearMax, plotX1, plotX2);
      fill(0);
      text(years[row],x,plotY2+10);
      if(displayMode>=4){
        stroke(255);
      }
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

/*
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
  
  if(key == '1'){
    displayMode = 1;
  } else if(key == '2'){
    displayMode = 2;
  } else if(key == '3'){
    displayMode = 3;
  } else if(key == '4'){
    displayMode = 4;
  } else if(key == '5'){
    displayMode = 5;
  }
}
*/

void mousePressed(){
  if( mouseY > tabTop && mouseY < tabBottom){
    for(int col=0; col<=columnCount; col++){
      if(mouseX > tabLeft[col] && mouseX < tabRight[col]){
        setColumn(col);
      }
    }
  }
}

void setColumn(int col){
  if( col != currentColumn){
    currentColumn = col;
    if( col == columnCount ){
      displayMode = 3;
    } else {
      displayMode = 4;
      for(int row=0; row<rowCount; row++){
        interpolators[row].target(data.getFloat(row,col));
      }
    }
  }
}
