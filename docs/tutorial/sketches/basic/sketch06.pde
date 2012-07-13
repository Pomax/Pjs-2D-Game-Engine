/* @pjs preload="idle.gif"; */

/**
 * We must set the screen dimensions to something
 */
final int screenWidth = 200;
final int screenHeight = 200;

/**
 * initializing means building an "empty"
 * level, which we'll 
 */
void initialize() {
  addScreen("mylevel", new MyLevel(width, height));  
}

/**
 * Our "empty" level is a single layer
 * level, doing absolutely nothing.
 */
class MyLevel extends Level {
  MyLevel(float levelWidth, float levelHeight) {
    super(levelWidth, levelHeight);
    addLevelLayer("my level layer", new MyLevelLayer(this));
  }
}

/**
 * Our main level layer has a background
 * color, and nothing else.
 */
class MyLevelLayer extends LevelLayer {
  MyLevelLayer(Level owner) {
    super(owner);
    setBackgroundColor(color(0,130,255));
    MyThingy mt = new MyThingy();
    mt.setPosition(width/2, height/2);
    addPlayer(mt);
    addBoundary(new Boundary(0,height, width,height));
    addBoundary(new Boundary(width,height, width,0));
    addBoundary(new Boundary(width,0,0,0));
    addBoundary(new Boundary(0,0,0,height));
  }
}


/**
 * Our controllable thingy
 */
class MyThingy extends Player {

  MyThingy() {
    super("thingy");
    setStates();
    handleKey('W');
    handleKey('A');
    handleKey('S');
    handleKey('D');
  }
  
  void setStates() {
    addState(new State("idle", "idle.gif"));
  }
  
  void handleInput() {
    if(isKeyDown('W')) { addImpulse(0,-1); }
    if(isKeyDown('A')) { addImpulse(-1,0); }
    if(isKeyDown('D')) { addImpulse(1,0); }
    if(isKeyDown('S')) { addImpulse(0,1); }
  }
}