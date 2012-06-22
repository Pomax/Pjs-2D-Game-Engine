float[] boundary, bbox;

void setup() {
  size(500,500);
  noLoop();
  reset();
}

void reset() {
  float sdx = random(-100,100), sdy = random(-100,100),
        edx = random(-100,100), edy = random(-100,100);
  boundary = new float[]{width/2+sdx, height/2+sdy, width/2+edx, height/2+edy};
  int v = 40, o=20, w = v+20;
  bbox = new float[]{v+o,v, w+o,v, w+o,w, v+o,w};
}

void draw() {
  background(0);

  // draw boundary and box
  stroke(255,200,200);
  line(boundary[0], boundary[1], boundary[2], boundary[3]);
  fill(255);
  text("s",boundary[0], boundary[1]);
  text("e",boundary[2], boundary[3]);


  /*
     Determine three sets of dot product values:

     1: dot product relative to boundary start
     2: dot product relative to boundary end
     3: dot product relative to line perpendicular to boundary
     
     These three sets let us determine whether something
     is in bounds, and whether it's above or below a boundary.
  */

  float x1=boundary[0], y1=boundary[1], x2=boundary[2], y2=boundary[3];
  float dx = x2-x1, dy = y2-y1, p=PI/2.0,
        rdx = dx*cos(p) - dy*sin(p),
        rdy = dx*sin(p) + dy*cos(p);

  float[] dotProducts1 = getDotProducts(x1,y1,x2,y2, bbox);
  float[] dotProducts2 = getDotProducts(x2,y2,x1,y1, bbox);
  float[] dotProducts3 = getDotProducts(x1,y1,x1+rdx,y1+rdy, bbox);

  int inRangeS = 4, inRangeE = 4, above = 0;
  for(int i=0; i<8; i+=2) {
    if(dotProducts1[i]<0) { inRangeS--; }
    if(dotProducts2[i]<0) { inRangeE--; }
    if(dotProducts3[i]<0) { above++; }
  }
  
  println("in range of s: "+inRangeS+", in range of e: "+inRangeE+", above line: "+above);

  if(inRangeS>0 && inRangeE>0) {
    if(above==4) { fill(200,0,0); }
    else { fill(0,0,200); }}
  else { noFill(); }

  stroke(255);
  drawBox(bbox);
}

float[] getDotProducts(float ox, float oy, float tx, float ty, float[] bbox) {
  float dotx = tx-ox, doty = ty-oy,
        otlen = sqrt(dotx*dotx + doty*doty),
        dx, dy, len, dotproduct;

  dotx /= otlen;
  doty /= otlen;
  
  float[] dotProducts = new float[8];

  for(int i=0; i<8; i+=2) {
    dx = bbox[i]-ox;
    dy = bbox[i+1]-oy;
    len = sqrt(dx*dx+dy*dy);
    dx /= len;
    dy /= len;
    dotproduct = dx*dotx + dy*doty;
    dotProducts[i]   = dotproduct;
  }

  return dotProducts;
}


void printArray(String prefix, float[] arr) {
  print(prefix);
  for(int i=0, e=arr.length; i<e; i++) {
    print(int(100*arr[i])/100.0);
    if(i<e-1) { print(", "); }
  }
  println();
}

void drawBox(float[] bbox) {
  beginShape();
  vertex(bbox[0], bbox[1]);
  vertex(bbox[2], bbox[3]);
  vertex(bbox[4], bbox[5]);
  vertex(bbox[6], bbox[7]);
  endShape(CLOSE);
}

void mouseMoved() {
  int w = 30,
      vx = mouseX - w/2,
      wx = mouseX + w/2,
      vy = mouseY - w/2,
      wy = mouseY + w/2;
  bbox = new float[]{vx,vy, wx,vy, wx,wy, vx,wy};
  redraw();
}

void mouseClicked() {
  reset();
  redraw();
}
