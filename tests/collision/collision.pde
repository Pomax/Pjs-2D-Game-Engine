/**
 * Collision detection
 */

float[] boundary, prev, bbox;
boolean blocked;
int quadrant;

void setup() {
  size(500,500);
  CollisionDetection.init(this);
  ellipseMode(CENTER);
  frameRate(1000);
  reset();
}

void reset() {
  quadrant = (int) random(1,5);

  int bsize = 160;
  float sdx = random(-bsize,bsize), sdy = random(-bsize,bsize),
        edx = random(-bsize,bsize), edy = random(-bsize,bsize);
  boundary = new float[]{width/2+sdx, height/2+sdy, width/2+edx, height/2+edy};

  int x = width/4, y=height/4, dx=24, dy=24;

  if(quadrant==1 || quadrant==4) { x = width-x; }
  if(quadrant==1 || quadrant==2) { y = height-y; }
  bbox = new float[]{x,y, x+dx,y, x+dx,y+dy, x,y+dy};
  prev = new float[]{0,0,0,0,0,0,0,0};
}

void draw() {
  fill(0,150);
  rect(-1,-1,width+2,height+2);

  // next frame's values
  nextFrame();

  // perform collision detection
  float[] correction = CollisionDetection.getLineRectIntersection(boundary, prev, bbox);
  if (correction != null) {
    updatePosition(correction[0], correction[1]);
  }

  // draw boundary and box
  stroke(255,200,200);
  line(boundary[0], boundary[1], boundary[2], boundary[3]);
  fill(255);
  text("s",boundary[0], boundary[1]);
  text("e",boundary[2], boundary[3]);
  
  stroke(125);
  drawBox(prev);
  stroke(255);
  drawBox(bbox);
  
  if(bbox[0]<0 || bbox[0]>width || bbox[1]<0 || bbox[1]>height) reset();
}

void drawBox(float[] boundingbox) {
  line(boundingbox[0], boundingbox[1], boundingbox[2], boundingbox[3]);
  line(boundingbox[2], boundingbox[3], boundingbox[4], boundingbox[5]);
  line(boundingbox[4], boundingbox[5], boundingbox[6], boundingbox[7]);
  line(boundingbox[6], boundingbox[7], boundingbox[0], boundingbox[1]);
}

void nextFrame() {
  arrayCopy(bbox,0,prev,0,8);
  float dx = random(15,25),
        dy = random(15,25);
  if(quadrant==1 || quadrant==4) { dx = -dx; }
  if(quadrant==1 || quadrant==2) { dy = -dy; }
  updatePosition(dx,dy);
}

void updatePosition(float dx, float dy) {
  for(int i=0; i<8; i+=2) {
    bbox[i] += dx;
    bbox[i+1] += dy;
  }
}

void mouseClicked() { reset(); loop(); }
void keyPressed() { reset(); loop(); }
