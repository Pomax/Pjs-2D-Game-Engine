// ====== LET'S GET OUR NINTENDO ON! ======

Level level;

/**
 * Test the actor class
 */
void setup()
{
  size(512,400);
  frameRate(24);
  SpriteMapHandler.setSketch(this);
  level = new TestLevel();
}

/**
 * Render mario in glorious canvas definition
 */
void draw() {
  level.draw();
}

// pass-through keyboard events
void keyPressed() { level.keyPressed(key,keyCode); }
void keyReleased() { level.keyReleased(key, keyCode); }


// ======================


// test the engine mechanics
class TestLevel extends Level {

  Actor actor;

  /**
   * Test the actor class
   */
  TestLevel()
  {
    // screen boundaries
    float pad = 10;
    boundaries.add(new Boundary(width-pad,pad,pad,pad));
    boundaries.add(new Boundary(width-pad,height-pad,width-pad,pad));
    boundaries.add(new Boundary(pad,height-pad,width-pad,height-pad));
    boundaries.add(new Boundary(pad,pad,pad,height-pad));

    // angled boundaries
    boundaries.add(new FullBoundary(width/4 + 0.5, 1*height/5 + 0.5, width/2 + 0.5, 3*height/5 + 0.5));
    //boundaries.add(new Boundary(width/2 - 0.5, 3*height/5 - 0.5, width/4 - 0.5, 1*height/5 - 0.5));
    boundaries.add(new Boundary(3*width/4, 3*height/5, width/4, 4*height/5));

    // test actor
    actor = new TestActor();
    actor.setPosition(width/2-5,height/2-5);
    actors.add(actor);
  }


  /**
   * Render mario in glorious canvas definition
   */
  void draw()
  {
    // trail graphics
    drawBackground();
    fill(255,50);
    rect(-1,-1,2+width,2+height);

    // game aspect!
    float angle = frameCount * PI/100;

    pushMatrix();
    pushStyle();
    translate(width/2, height/2);
    stroke(100,200,100);
    strokeWeight(10);
    rotate(angle);
    int len = 70;
    line(0,0,len,0);
    line(len-10,-10,len,0);
    line(len-10, 10,len,0);
    popStyle();
    popMatrix();

    float fx = cos(angle);
    float fy = sin(angle);
    actor.setForces(fx, fy);

    // draw level the standard way
    super.draw();
  }
}

class TestActor extends Actor {

  float speedStep = 2;

  TestActor() { super(0.8, 0.8); }

  void handleInput() {
    if(keyDown[LEFT])  { addImpulse(-speedStep,0); }
    if(keyDown[UP])    { addImpulse(0,-speedStep); }
    if(keyDown[RIGHT]) { addImpulse(speedStep, 0); }
    if(keyDown[DOWN])  { addImpulse(0, speedStep); }
  }

  void handleStateFinished(State which) {
    // does nothing
  }
}
