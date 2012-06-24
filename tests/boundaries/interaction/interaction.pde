
float[] old, prev, bbox;
ArrayList<float[]> boundaries = new ArrayList<float[]>();
ArrayList<float[]> attached = new ArrayList<float[]>();

int padding = 60;
float epsilon = 0.5;
int skipover = 0;


/**
 * Boilerplate setup
 */
void setup() {
  size(800,800);
  CollisionDetection.init(this);
  ellipseMode(CENTER);
  frameRate(1000);
  reset();
}


/**
 * Reset the world
 */
void reset() {
  skipover = 0;

  int x = width/2, y=height/2-100, dx=24, dy=24;
  bbox = new float[]{x,y, x+dx,y, x+dx,y+dy, x,y+dy};
  prev = new float[]{0,0,0,0,0,0,0,0};
  old  = new float[]{0,0,0,0,0,0,0,0};

  boundaries.clear();
  attached.clear();
  
  // bounding poly
  boundaries.add(new float[]{padding,padding,padding,height-padding});
  boundaries.add(new float[]{padding,height-padding,width-padding,height-padding});
  boundaries.add(new float[]{width-padding,height-padding,width-padding,padding});
  boundaries.add(new float[]{width-padding,padding,padding,padding});
}

/**
 * Boilerplate draw function
 */
void draw() {
  fill(0,150);
  rect(-1,-1,width+2,height+2);

  if(bbox[0]<padding || bbox[2]>width-padding || bbox[1]<padding || bbox[5]>height-padding) {
    println(frameCount +"> **************************************************************");
    println(frameCount +"> box found in illegal position, noLoop will be called ("+bbox[0]+"--"+bbox[2]+"/"+bbox[1]+"--"+bbox[5]+")");
    println(frameCount +"> **************************************************************");
    noLoop();
    skipover++;
  }

  // draw boundaries and box
  int intensity = 0;
  for(float[] boundary: boundaries) {
    stroke(100 + intensity++*20,100 + intensity++*20,200);
    line(boundary[0], boundary[1], boundary[2], boundary[3]);
  }

  stroke(0,0,255);
  drawBox(old);

  stroke(127,200,255);
  drawBox(prev);

  stroke(255);
  drawBox(bbox);

  // try to update
  nextFrame();

  println(frameCount + "> end of draw function");
}


// helper draw function for showing box wireframes
void drawBox(float[] boundingbox) {
  line(boundingbox[0], boundingbox[1], boundingbox[2], boundingbox[3]);
  line(boundingbox[2], boundingbox[3], boundingbox[4], boundingbox[5]);
  line(boundingbox[4], boundingbox[5], boundingbox[6], boundingbox[7]);
  line(boundingbox[6], boundingbox[7], boundingbox[0], boundingbox[1]);
}


float dx = 1, dy = 0;


/**
 * Move the actor by some random x/y value.
 * (constrained by padding in the function)
 *
 * This move is treated as a "next frame" position.
 */
void nextFrame() {
  if(skipover==1) return;
  skipover = 0;

  arrayCopy(prev,0,old,0,8);
  arrayCopy(bbox,0,prev,0,8);
  println("\n"+frameCount +"> advancing frame ("+dx+"/"+dy+")");
  
  if(attached.size()>0) {
    float[] redirected = {dx, dy};
    for(int a=attached.size()-1; a>=0; a--) {
      redirected = redirectOverBoundary(redirected, attached.get(a));
      if (redirected[2] < 0) { attached.remove(a); }
    }
    updatePosition(redirected[0], redirected[1]);
  } else { updatePosition(dx,dy); }
  
  // perform collision detection based on these values
  println(frameCount + "> performing collision detection");
  boolean repositioned = false;
  for(int b=0, last=boundaries.size(); b<last; b++) {
    float[] boundary = boundaries.get(b);
    // skip over boundaries we're (still) attached to.
    if(attached.contains(boundary)) continue;
    // performed collision detection for all boundaries we're not attached to. 
    float[] correction = CollisionDetection.getLineRectIntersection(boundary, prev, bbox);
    if (correction != null) {
      println(frameCount + "> received dx/dx "+correction[0]+"/"+correction[1]+" on boundary "+b);
      updatePosition(correction[0], correction[1]);
      repositioned = true;
      attached.add(boundary);
    }
  }
}


/**
 * Move the actor by some specific x/y value.
 * This move is NOT treated as a "next frame" position
 */
void updatePosition(float dx, float dy) {
  if(skipover==1) return;

  println(frameCount + "> updating position by "+dx+"/"+dy);  
  for(int i=0; i<8; i+=2) {
    bbox[i] += dx;
    bbox[i+1] += dy;
  }
}


/**
 * redirect a force along a boundary's surface
 */
float[] redirectOverBoundary(float[] forceVector, float[] boundary) {
  // is this a permissible vector?
  float[] refVector = {boundary[2]-boundary[0], boundary[3]-boundary[1]};
  float dx = refVector[0], dy = refVector[1], pv=PI/2.0,
        rdx = dx*cos(pv) - dy*sin(pv),
        rdy = dx*sin(pv) + dy*cos(pv);
  float dotproduct = CollisionDetection.getDotProduct(rdx, rdy, forceVector[0], forceVector[1]);
  println(dotproduct);
  if(dotproduct<0) { return new float[]{forceVector[0], forceVector[1], dotproduct}; }
  
  // no it's not. redirect it.
  dotproduct = forceVector[0]*refVector[0] + forceVector[1]*refVector[1];
  float len = refVector[0]*refVector[0] + refVector[1]*refVector[1],
        scalar = dotproduct / len;
  float[] redirected = {scalar*refVector[0], scalar*refVector[1]};
  println(frameCount+"> "+forceVector[0]+","+forceVector[1]+" over "+refVector[0]+","+refVector[1]+" = "+redirected[0]+","+redirected[1]);
  return new float[]{redirected[0], redirected[1], 0};
}

// =======================

void mouseClicked() { if(mouseButton==LEFT) reset(); loop(); }
void keyPressed() {
  if(key=='w') { dy = -20; }
  if(key=='a') { dx = -20; }
  if(key=='s') { dy = 20; }
  if(key=='d') { dx = 20; }
  if(key==' ') { reset(); loop(); }
}

void keyReleased() {
  dx = 1;
  dy = 0;
}

//void println(String s) {}

