/* @pjs preload="static.gif"; pausOnBlur="true"; */

Level level;
final float DAMPEN = 0.7;
final float GRAVITY = 3;

void setup() {
  size(400,400);
  SpriteMapHandler.init(this);
  level = new TestLevel(width, height);
  frameRate(8);
}

void draw() {
  level.draw();
}

void keyPressed() { level.keyPressed(key,keyCode); }
void keyReleased() { level.keyReleased(key,keyCode); }

void mousePressed() { 
  if(mouseButton == LEFT) {
    noLoop();
    redraw();
  } else {
    loop();
  }
} //level.mousePressed(mouseX,mouseY,mouseButton); }
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
    if(keyDown[VK_UP])    { addImpulse(0,-5); }
    if(keyDown[VK_DOWN])  { addImpulse(0, 1); }
    if(keyDown[VK_LEFT])  { addImpulse(-1,0); }
    if(keyDown[VK_RIGHT]) { addImpulse( 1,0); }

    setViewDirection(ix, iy);
    //setRotation(direction);
  }
  
  void draw() {
    super.draw();
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
    debugfunctions_drawBackground(400,400);
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
    int p = 20, wp = width-p, hp = height-p;
//    addBoundary(new Boundary(wp, p, p, p));
//    addBoundary(new Boundary(p, p, p, hp));
    addBoundary(new Boundary(p, hp-100, wp, hp));
    addBoundary(new Boundary(p, hp+50, wp, hp-100));
//    addBoundary(new Boundary(wp, hp, wp, p));    

//    addBoundary(new Boundary(p+20, hp-40, p+20+20, hp-40));

  }
  
  void draw() {
    debugfunctions_drawBackground(width, height);
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


