/**
 * Collision detection
 */

float[] old, prev, bbox;
ArrayList<float[]> boundaries = new ArrayList<float[]>();
int padding = 60;
int skipover = 0;

void setup() {
  size(500,500);
  CollisionDetection.init(this);
  ellipseMode(CENTER);
  frameRate(1000);
  reset();
}

void reset() {
  skipover = 0;

  int x = width/2, y=height/2, dx=24, dy=24;
  bbox = new float[]{x,y, x+dx,y, x+dx,y+dy, x,y+dy};
  prev = new float[]{0,0,0,0,0,0,0,0};
  old  = new float[]{0,0,0,0,0,0,0,0};

  boundaries.clear();
  boundaries.add(new float[]{padding,padding,padding,height-padding});
  boundaries.add(new float[]{padding,height-padding,width-padding,height-padding});
  boundaries.add(new float[]{width-padding,height-padding,width-padding,padding});
  boundaries.add(new float[]{width-padding,padding,padding,padding});
}

void draw() {
//  println(frameCount +"> draw");
  
  if(bbox[0]<padding || bbox[2]>width-padding || bbox[1]<padding || bbox[5]>height-padding) {
//  println(frameCount +"> noLoop will be called");
    noLoop();
    skipover++;
  }

  fill(0,15);
  rect(-1,-1,width+2,height+2);

  // draw boundary and box
  int intensity = 0;
  for(float[] boundary: boundaries) {
    stroke(100 + intensity++*20,100 + intensity++*20,200);
    line(boundary[0], boundary[1], boundary[2], boundary[3]);
  }
  
  if(bbox[0]<padding || bbox[2]>width-padding || bbox[1]<padding || bbox[5]>height-padding) {
    stroke(255,0,0,150);
    line(prev[0],prev[1],bbox[0],bbox[1]);
    line(prev[2],prev[3],bbox[2],bbox[3]);
    line(prev[4],prev[5],bbox[4],bbox[5]);
    line(prev[6],prev[7],bbox[6],bbox[7]);
  }

  stroke(0,0,255);
  drawBox(old);

  stroke(127,200,255);
  drawBox(prev);

  stroke(255);
  drawBox(bbox);

  if(skipover!=1) {
    skipover = 0;    
    // next frame's values
    nextFrame();
  
    // perform collision detection
    boolean repositioned = false;
    for(float[] boundary: boundaries) {
      float[] correction = CollisionDetection.getLineRectIntersection(boundary, prev, bbox);
      if (correction != null) {
        updatePosition(correction[0], correction[1]);
        repositioned = true;
//        println(frameCount +"> blocked");
      }
    }
  }
}

void drawBox(float[] boundingbox) {
  line(boundingbox[0], boundingbox[1], boundingbox[2], boundingbox[3]);
  line(boundingbox[2], boundingbox[3], boundingbox[4], boundingbox[5]);
  line(boundingbox[4], boundingbox[5], boundingbox[6], boundingbox[7]);
  line(boundingbox[6], boundingbox[7], boundingbox[0], boundingbox[1]);
}

void nextFrame() {
  arrayCopy(prev,0,old,0,8);
  arrayCopy(bbox,0,prev,0,8);
  int maxStep = 150;
  float dx = random(-maxStep,maxStep),
        dy = random(-maxStep,maxStep);
  updatePosition(dx,dy);
}

void updatePosition(float dx, float dy) {
  float securityFactor = 1.1;
  for(int i=0; i<8; i+=2) {
    bbox[i] += dx * securityFactor;
    bbox[i+1] += dy * securityFactor;
  }
}

void mouseClicked() { if(mouseButton==LEFT) reset(); loop(); }
void keyPressed() { reset(); loop(); }
