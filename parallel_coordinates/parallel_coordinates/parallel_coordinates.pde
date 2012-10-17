FloatTable data;
String data_fn;
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

float smPlotX1;
float smPlotX2;


float paramMin, paramMax;
int [] paramOrdering;
int [] suggestedOrdering;

PFont plotFont;
PFont headingFont;
PFont labelFont;

int draggingRegion = -1;
String draggingWord;
float drag_x, drag_y;
int overRegion = -1;

int sumthing(int n){
  int sum = 0;
  for(int i=1;i<=n;++i) sum +=i;
  return sum;
}

void setup(){
  size(1320,605);
  data_fn = "cars.tsv";
  data = new FloatTable(data_fn);
  columnCount = data.getColumnCount();
  rowCount = data.getRowCount();
  numCoordinates = columnCount;
  coordinateLocs = new float[numCoordinates];

  paramOrdering = new int[numCoordinates];
  suggestedOrdering = new int[2*sumthing(numCoordinates-1)];
  for(int i=0; i<numCoordinates; ++i){
    paramOrdering[i] = i; // default ordering is 0 to N-1
  }
  getSuggestions();

  // corners:
  // small multiples:
  smPlotX1 = 120;
  smPlotX2 = .3 * width;
  // parallel coordinates:
  plotX1 = smPlotX2 + 50;
  plotX2 = width-80;
  plotY1 = 90;
  plotY2 = height-70;
  
  plotFont = createFont("Verdana",12);
  headingFont = createFont("Verdana",24);
  labelFont = createFont("Verdana",8);

  dataMin = new float[columnCount];
  dataMax = new float[columnCount];
  for(int col=0; col<columnCount; ++col){
    dataMin[col] = data.getColumnMin(col);
    dataMax[col] = data.getColumnMax(col);
  }
}

void draw(){

  background(224);
  
  //////////////////////////////
  // Parallel coordinates stuff
  
  // show main plot area as a white box
  fill(255);
  rectMode(CORNERS);
  noStroke();
  rect(plotX1,plotY1, plotX2,plotY2);

  // draw coordinate bars
  drawCoordinateBars();
  drawCoordinateBarLabels();
  drawCoordinateBarTitles();
  
  stroke(#5679C1);
  strokeWeight(4);
  //drawDataPoints(currentColumn);
  drawLines();
  
  ///////////////////////////////
  // small multiples stuff
  overRegion = -1;
  fill(255);
  rectMode(CORNERS);
  noStroke();
  rect(smPlotX1,plotY1, smPlotX2,plotY2);

  float half_x = smPlotX1 + .5*(smPlotX2-smPlotX1);
  float divider_border = 10;
  
  fill(#5679C1);
  textFont(plotFont);
  textAlign(CENTER);
  text("Suggestions", smPlotX1+(half_x-smPlotX1)/2, plotY1-10);
  text("Current", half_x+(half_x-smPlotX1)/2, plotY1-10);
  //divider:
  stroke(150);
  strokeWeight(2);
  line(half_x,plotY1,half_x,plotY2);
  // draw small multiples for stuff on parallel coordinates:
  float perMultipleSpace = (plotY2-plotY1)/(columnCount-1);
  drawScatterPlot( half_x+divider_border, 
                   plotY2-perMultipleSpace, 
                   smPlotX2-divider_border, 
                   plotY2, 
                   paramOrdering[0], 
                   paramOrdering[1] ,
                   true,
                   true);
  for(int i=1; i<columnCount-1; ++i){
    drawScatterPlot( half_x+divider_border, 
                     plotY2-(i+1)*perMultipleSpace, 
                     smPlotX2-divider_border,
                     plotY2-i*perMultipleSpace, 
                     paramOrdering[i], 
                     paramOrdering[i+1],
                     true,
                     true);
  }
                     
  // now draw suggested parameter positionings..
  drawScatterPlot( smPlotX1+divider_border, 
                   plotY2-perMultipleSpace, 
                   half_x-divider_border, 
                   plotY2, 
                   suggestedOrdering[0], 
                   suggestedOrdering[1],
                   true,
                   true);
  int drawi=1;
  for(int i=2; i<suggestedOrdering.length-1 && (i/2)<columnCount-1; i+=2){
    drawScatterPlot( smPlotX1+divider_border, 
                     plotY2-(drawi+1)*perMultipleSpace, 
                     half_x-divider_border, 
                     plotY2-drawi*perMultipleSpace, 
                     suggestedOrdering[i], 
                     suggestedOrdering[i+1],
                     true,
                     true);
                     ++drawi;
  }
  
  // dragging draw:
  if(draggingRegion >= 0){
    fill(#5679C1);
    textFont(plotFont);
    textAlign(CENTER);
    text(draggingWord,mouseX,mouseY);
  }
}

void getSuggestions(){
  // for now this just sorts all possiblities by pearon's r.. but 
  // could potentially do other things..
  float [] best_r = new float[suggestedOrdering.length/2];
  for(int i=0; i<best_r.length; ++i) best_r[i] = 0;
  
  print("computing suggestions...\n");
  for(int i=0; i<columnCount; ++i){
    for(int j=i+1; j<columnCount; ++j){
      float r = samplePearsonCoefficient(i,j);
      for(int k=0; k<best_r.length; ++k){
        if( abs(r) > best_r[k] ){
          // insert and move back everything..
          for(int l=columnCount-1;l>=k+1;--l){
            best_r[l] = best_r[l-1];
          }
          for(int l=suggestedOrdering.length-1-1;l>=2*(k+1);l-=2)
          {
             suggestedOrdering[l] = suggestedOrdering[l-2];
             suggestedOrdering[l+1] = suggestedOrdering[l+1-2];
          }
          best_r[k] = abs(r);
          suggestedOrdering[k*2] = i;
          suggestedOrdering[k*2+1] = j;
          break;
        }
      }
    }
  }
  print("done computing suggestions.\n");
}


/**
 * @param topLeft_x,y,bottomRight_x,y - enclosing rectangle of plot
 * @param param1,2 - column numbers of parameters we are scatterplotting
 *          NOTE: param1 will be plotted on x-axis, param2 on y-axis
 * @param labelTop,Bottom - whether or not to draw the label on the bottom (x-axis) or top (y-axis)
 */
void drawScatterPlot( float topLeft_x, float topLeft_y, float bottomRight_x, float bottomRight_y, int param1, int param2, boolean labelBottom, boolean labelTop ){
  
  // check if mouse is over this region..
  if(topLeft_x <= mouseX && mouseX <= bottomRight_x && topLeft_y <= mouseY && mouseY <= bottomRight_y){
    // decide if it's over the top or bottom variable..
    float halfway = bottomRight_y + (topLeft_y-bottomRight_y)/2;
    if(mouseY > halfway){
      overRegion = param2;
    }else{
      overRegion = param1;
    }
  }
  
  // add spacing
  float labelSpace = 15; // spacing for labels at top and bottom..
  float coefficientSpace = 27;
  float boxTopLeft_x = topLeft_x;
  float boxTopLeft_y = topLeft_y;
  float boxBottomRight_x = bottomRight_x-coefficientSpace;
  float boxBottomRight_y = bottomRight_y;

  // draw labels:
  if(labelTop){
    boxTopLeft_y += labelSpace;
    fill(0);
    textFont(plotFont);
    textAlign(CENTER);
    String title = data.getColumnName(param1);
    text(title,(topLeft_x+bottomRight_x)/2, bottomRight_y);
  }
  if(labelBottom){
    boxBottomRight_y -= labelSpace;
    fill(0);
    textFont(plotFont);
    textAlign(CENTER);
    String title = data.getColumnName(param2);
    text(title,(topLeft_x+bottomRight_x)/2, boxTopLeft_y-2);
  }
  
  // draw coefficient:
  float r = samplePearsonCoefficient(param1,param2);
  fill(0);
  textFont(plotFont);
  textAlign(LEFT);
  text(nf(r,1,2), boxBottomRight_x, (boxTopLeft_y+boxBottomRight_y)/2);
  
  // draw border:
  float border = 3;
  fill(100);
  rectMode(CORNERS);
  noStroke();
  rect(boxTopLeft_x,boxTopLeft_y, boxBottomRight_x,boxBottomRight_y);
  fill(255);
  boxTopLeft_x+=border;
  boxTopLeft_y+=border;
  boxBottomRight_x-=border;
  boxBottomRight_y-=border;
  rect(boxTopLeft_x,boxTopLeft_y, boxBottomRight_x,boxBottomRight_y);
  
  // draw points:
  stroke(0);
  strokeWeight(4);
  for(int row=0; row<rowCount; ++row){
    if(data.isValid(row,param1) && data.isValid(row,param2)){
      float value1 = data.getFloat(row,param1);
      float value2 = data.getFloat(row,param2);
      float x = map(value1, dataMin[param1], dataMax[param1], boxTopLeft_x, boxBottomRight_x);
      float y = map(value2, dataMin[param2], dataMax[param2], boxBottomRight_y, boxTopLeft_y);
      point(x,y);
    }
  }
}

void drawCoordinateBars(){
  fill(#5679C1);
  rectMode(CORNERS);
  noStroke();
  for(int c=0; c<numCoordinates;c++){
    float xloc = map(c,0,numCoordinates-1,plotX1,plotX2);
    coordinateLocs[c] = xloc;
    float xstart = xloc-coordinateBarWidth/2;
    float xend = xloc+coordinateBarWidth/2;
    rect(xstart,plotY1, xend,plotY2);
  }
}

boolean overSection(int c){
  if( c >= (numCoordinates-1) ) c=numCoordinates-2;
  if( c < 0 ) c=0;
  float x1 = coordinateLocs[c];
  float x2 = coordinateLocs[c+1];
  return (plotY1 <= mouseY && mouseY <= plotY2) && (x1 <= mouseX && mouseX <= x2);
}

void drawCoordinateBarLabels(){
  fill(#5679C1);
  rectMode(CORNERS);
  noStroke();
  for(int c=0; c<numCoordinates-1;c++){
    if(overSection(c)){
      // mouse is over the area between params c and c+1, draw their labels..
      float x1 = coordinateLocs[c];
      float x2 = coordinateLocs[c+1];
            
      // draw values
      fill(0);
      textFont(plotFont);
      textAlign(CENTER);
      text(""+dataMin[paramOrdering[c]], x1, plotY1-2);
      text(""+dataMin[paramOrdering[c+1]], x2, plotY1-2);
      text(""+dataMax[paramOrdering[c]], x1, plotY2+10);
      text(""+dataMax[paramOrdering[c+1]], x2, plotY2+10);
      
      //textSize(10);
      //textAlign(CENTER);
      //text(nf(value, 0, 2) + " (" + years[row] + ")", x, y-8);
    }
  }
}

void drawCoordinateBarTitles(){
  textFont(plotFont);
  textAlign(CENTER);
  for(int c=0; c<columnCount; ++c){
    if(overSection(c)||overSection(c-1)){
      fill(0);
    }else{
      fill(100);
    }
    int column = paramOrdering[c];
    String title = data.getColumnName(column);
    text(title, coordinateLocs[c], plotY1-17);
  }
  
  // and heading:
  textFont(headingFont);
  text(data_fn, (plotX1+plotX2)/2, plotY1-50);
}

void drawLines(){
  stroke(#56C1C1);
  strokeWeight(1);
  noFill();
  for(int row=0; row<rowCount; ++row){
    //stroke(colors[color_i++]);
    beginShape();
    for(int c=0; c<columnCount; ++c){
      int col = paramOrdering[c];
      if(data.isValid(row,col)){
        float value = data.getFloat(row,col);
        float x = coordinateLocs[c]; //map(row, 0, rowCount, plotX1,plotX2);
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

void mousePressed(){
  draggingRegion = overRegion;
  draggingWord = data.getColumnName(draggingRegion);
}


void mouseRelease(){
  int targetRegion = overRegion;
  if( targetRegion >= 0){
    for(int i=0; i<paramOrdering.length; ++i){
      if( paramOrdering[i] == targetRegion ){
        paramOrdering[i] = draggingRegion;
      }
      if( paramOrdering[i] == draggingRegion ){
        paramOrdering[i] = targetRegion;
      }
    }
  }
  draggingRegion = -1;
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

/** calculate the sample pearson coefficient.
 * see http://en.wikipedia.org/wiki/Pearson_product-moment_correlation_coefficient
 */
 
float samplePearsonCoefficient(int param1, int param2){
  float mean1 = 0;
  float mean2 = 0;
  int count = 0;
  for(int r=0; r<rowCount; ++r){
    if(data.isValid(r,param1) && data.isValid(r,param2)){
      mean1 += data.getFloat(r,param1);
      mean2 += data.getFloat(r,param2);
      ++count;
    }
  }
  mean1 /= count;
  mean2 /= count;
  
  float numerator = 0;
  float den1 = 0;
  float den2 = 0;
  for(int r=0; r<rowCount; ++r){
    if(data.isValid(r,param1) && data.isValid(r,param2)){
      float diff1 = mean1-data.getFloat(r,param1);
      float diff2 = mean2-data.getFloat(r,param2);
      numerator += diff1*diff2;
      den1 += diff1*diff1;
      den2 += diff2*diff2;
    }
  }
  float r = numerator/ ( sqrt(den1)*sqrt(den2) );
  return r;
}

