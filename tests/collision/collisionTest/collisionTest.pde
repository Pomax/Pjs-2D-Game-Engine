/**
 * Collision detection
 */

float[] old, prev, bbox;
ArrayList<float[]> boundaries = new ArrayList<float[]>();
int padding = 60, jitter = 40;
float epsilon = 0.5;
int skipover = 0;

ArrayList<float[]> attached = new ArrayList<float[]>();

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
  
  // bounding poly
  boundaries.add(new float[]{padding+50,padding,padding-50,height-padding});
  boundaries.add(new float[]{padding-50,height-padding,width-padding+50,height-padding});
  boundaries.add(new float[]{width-padding+50,height-padding,width-padding-50,padding});
  boundaries.add(new float[]{width-padding-50,padding,padding+50,padding});

  // intermediary boundaries
  for(int i=0, f=0; i<9; i++) {
    f = i*50;
    boundaries.add(new float[]{-200 + f + width/2-dx/3,height/2, -200 + f + width/2+dx/3,height/2});
    //boundaries.add(new float[]{-200 + f + width/2+dx/3,height/2, -200 + f + width/2+dx/3,height/2+10});
    //boundaries.add(new float[]{-200 + f + width/2+dx/3,height/2+10, -200 + f + width/2-dx/3,height/2+10});
    //boundaries.add(new float[]{-200 + f + width/2-dx/3,height/2+10, -200 + f + width/2-dx/3,height/2});
  }
}

boolean customtest = false;

/**
 * Boilerplate draw function
 */
void draw() {
  if(customtest) {
    noLoop();
/*
3824>  testing against: 242.0, 400.0, 258.0, 400.0
3824>   previous: 244.18, 384.89, 268.18, 384.89, 268.18, 408.89, 244.18, 408.89
3824>   current : 187.08, 384.02, 211.08, 384.02, 211.08, 408.02, 187.08, 408.02

2948>  testing against: 740.0, 740.0, 740.0, 60.0
2948>   previous: 716.0, 300.0, 740.0, 300.0, 740.0, 324.0, 716.0, 324.0
2948>   current : 717.0, 290.0, 741.0, 290.0, 741.0, 314.0, 717.0, 314.0
*/
    float[] testline = {740.0, 740.0, 740.0, 60.0};
    float[] previous = {716.0, 300.0, 740.0, 300.0, 740.0, 324.0, 716.0, 324.0};
    float[] current = {717.0, 290.0, 741.0, 290.0, 741.0, 314.0, 717.0, 314.0};
    float[] correction = CollisionDetection.getLineRectIntersection(testline, previous, current);
    if(correction!=null) {
      background(255);
      stroke(0);
      line(testline[0],testline[1],testline[2],testline[3]);
      stroke(0,0,200);
      drawBox(previous);
      stroke(100,100,100);
      drawBox(current);
      stroke(255,0,0);
      float x = (current[0]+current[2])/2;
      float y = (current[1]+current[5])/2;
      float dx = correction[0];
      float dy = correction[1];
      line(x,y,x+dx,y+dy);
      ellipse(x,y,5,5);
      
      print(frameCount + "> corrected: ");
      for(int i=0; i<8; i+=2) {
        current[i] += dx;
        current[i+1] += dy;
        print(current[i] + ", "+ current[i+1]);
        if(i<6) { print(", "); }}
      println();

      if(current[0]<padding-epsilon || current[2]>width+epsilon-padding || current[1]<padding-epsilon || current[5]>height+epsilon-padding) {
        println("VIOLATION");
      }
    }
    return;
  }
  
  fill(0,150);
  rect(-1,-1,width+2,height+2);

  if(bbox[0]<0 || bbox[2]>width || bbox[1]<0 || bbox[5]>height) {
    println(frameCount +"> box found in illegal position, noLoop will be called");
    noLoop();
    skipover++;
  }

  // draw boundary and box
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
  if(skipover!=1) {
    skipover = 0;

    // set up the next frame's values
    nextFrame();
  
    // perform collision detection for these values
    boolean repositioned = false;
    for(float[] boundary: boundaries) {
      float[] correction = CollisionDetection.getLineRectIntersection(boundary, prev, bbox);
      if (correction != null) {
        updatePosition(correction[0], correction[1]);
        repositioned = true;
        attached.add(boundary);
//        println(frameCount +"> blocked");
      }
    }
  }
}

// helper draw function for showing box wireframes
void drawBox(float[] boundingbox) {
  line(boundingbox[0], boundingbox[1], boundingbox[2], boundingbox[3]);
  line(boundingbox[2], boundingbox[3], boundingbox[4], boundingbox[5]);
  line(boundingbox[4], boundingbox[5], boundingbox[6], boundingbox[7]);
  line(boundingbox[6], boundingbox[7], boundingbox[0], boundingbox[1]);
}

/**
 * Move the actor by some random x/y value.
 * (constrained by padding in the function)
 *
 * This move is treated as a "next frame" position.
 */
void nextFrame() {
  arrayCopy(prev,0,old,0,8);
  arrayCopy(bbox,0,prev,0,8);
  float dx = random(-jitter,jitter),
        dy = random(-jitter,jitter);
  println("\n"+frameCount +"> advancing frame ("+dx+"/"+dy+")");
  updatePosition(dx,dy);
}

/**
 * Move the actor by some specific x/y value.
 * This move is NOT treated as a "next frame" position
 */
void updatePosition(float dx, float dy) {
  for(int i=0; i<8; i+=2) {
    bbox[i] += dx;
    bbox[i+1] += dy;
  }
}

void mouseClicked() { if(mouseButton==LEFT) reset(); loop(); }
void keyPressed() { reset(); loop(); }

//void println(String s) {}
