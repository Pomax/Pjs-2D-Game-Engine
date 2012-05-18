/* @pjs preload="static.gif"; */

Level level;
final float DAMPEN = 0.5;

void setup() {
  size(400,400);
  SpriteMapHandler.setSketch(this);
  level = new TestLevel(width, height);
}

void draw() {
  level.draw();
}

void keyPressed() { level.keyPressed(key,keyCode); }
void keyReleased() { level.keyReleased(key,keyCode); }


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
  }

  void setupStates() {
    State stt = new State("static", "static.gif", 1, 1);
    addState(stt);
  }
  
  void handleInput() {
    if(keyDown[VK_UP])    { addImpulse(0,-1); }
    if(keyDown[VK_DOWN])  { addImpulse(0, 1); }
    if(keyDown[VK_LEFT])  { addImpulse(-1,0); }
    if(keyDown[VK_RIGHT]) { addImpulse( 1,0); }
    setViewDirection(ix, iy);
    setRotation(direction);
  }

  /**
   * left mouse acts as Q, right mouse acts as E
   */
  void mousePressed(int mx, int my, int button) {
    if(button==LEFT) { keyPressed('Q',81); }
    else if(button==RIGHT) { keyPressed('E',69); }}
  void mouseReleased(int mx, int my, int button) {
    if(button==LEFT) { keyReleased('Q',81); }
    else if(button==RIGHT) { keyReleased('E',69); }}
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
    addBoundary(new Boundary(wp, p, p, p));
    addBoundary(new Boundary(p, p, p, hp));
    addBoundary(new Boundary(p, hp, wp, hp));
    addBoundary(new Boundary(wp, hp, wp, p));    
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


