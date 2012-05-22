/***********************************
 *                                 *
 *     This file does nothing,     *
 *    but allows Processing to     *
 *     actually load the code      *
 *    if located in a directory    *
 *     of the same name. Feel      *
 *       free to rename it.        * 
 *                                 *
 ***********************************/
 
 
 
 /* @pjs preload="static.gif"; */

Level level;
final float DAMPEN = 0.7;
final float GRAVITY = 1;

void setup() {
  size(400,400);
  SpriteMapHandler.setSketch(this);
  level = new TestLevel(width, height);
  //frameRate(4);
}

void draw() {
  level.draw();
  //if(frameCount>10) noLoop();
}

void keyPressed() { level.keyPressed(key,keyCode); redraw(); }
void keyReleased() { level.keyReleased(key,keyCode); redraw(); }

void mousePressed() { redraw(); } //level.mousePressed(mouseX,mouseY,mouseButton); }
//void mouseReleased() { level.mouseReleased(mouseX,mouseY,mouseButton); }


// ==================================
//       CLASS CODE STARTS HERE
// ==================================


/**
 * Player implementation
 */
class TestPlayer extends Player {

  int VK_UP=87, VK_LEFT=65, VK_DOWN=83, VK_RIGHT=68;  // WASD controls
  int BUTTON_A=81, BUTTON_B=69;                       // Q and E for jump/shoot

  TestPlayer(String name, int xpos, int ypos) {
    super(name);
    keyCodes = new int[] {VK_UP, VK_LEFT, VK_DOWN, VK_RIGHT, BUTTON_A, BUTTON_B};
    setupStates();
    setPosition(xpos, ypos);
    setImpulseCoefficients(DAMPEN,DAMPEN);
    setForces(0,GRAVITY);
  }

  void setupStates() {
    State stt = new State("static", "static.gif", 1, 1);
    addState(stt);

    stt = new State("jump", "static.gif", 1, 1);
    stt.sprite.addPathLine(0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 24);
    stt.sprite.setLooping(false);
    addState(stt);
    
    setCurrentState("static");
  }
  
  void handleInput() {
    if(keyDown[VK_UP])    { addImpulse(0,-2); }
    if(keyDown[VK_DOWN])  { addImpulse(0, 1); }
    if(keyDown[VK_LEFT])  { addImpulse(-1,0); }
    if(keyDown[VK_RIGHT]) { addImpulse( 1,0); }

    setViewDirection(ix, iy);
    //setRotation(direction);
  }
  
  void draw(float vx, float vy, float vw, float vh) {
    super.draw(vx,vy,vw,vh);
    stroke(255,0,0);
//    println("draw: "+ix+","+iy);
    line(getX(),getY(),getX()+10*ix, getY()+10*iy);
    stroke(0,0,255);
    line(getX(),getY(),getX()+10*fx, getY()+10*fy);
    stroke(0);
  }
  
  void handleStateFinished(State which) {
    if (which.name == "jump") {
      setCurrentState("static");
    }
  }

  void gotBlocked(Boundary b, ArrayList<float[]> intersection) {
    setCurrentState("static");
  }

  /**
   * left mouse acts as Q, right mouse acts as E
   */
  void mousePressed(int mx, int my, int button) {
    drawBackground(400,400);
    setPosition(200,0);
    setImpulse(0,0);
  }
}


/**
 * Level Layer implementation
 */
class TestLevelLayer extends LevelLayer {
  TestLevelLayer(Level parent, int w, int h) {
    super(parent, w, h);
    addPlayer(new TestPlayer("test", w/2, h/2));

    showBoundaries = true;
    float p = 20, wp = width-p, hp = height-p;
//    addBoundary(new Boundary(wp, p, p, p));
//    addBoundary(new Boundary(p, p, p, hp));
    addBoundary(new Boundary(p, hp, wp, hp-100));
    addBoundary(new Boundary(p, hp-100, wp, hp));
//    addBoundary(new Boundary(wp, hp, wp, p));    

//    addBoundary(new Boundary(p+20, hp-40, p+20+20, hp-40));

  }
  
  void draw() {
    drawBackground(width, height);
    super.draw();
  }
}


/**
 * Level implementation
 */
class TestLevel extends Level {
  TestLevel(int w, int h) {
    super(w,h);
    addLevelLayer("main", new TestLevelLayer(this, w, h));
  }
}


