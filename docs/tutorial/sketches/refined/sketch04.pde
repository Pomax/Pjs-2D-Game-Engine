/**
 * We must set the screen dimensions to something
 */
final int BLOCK = 16,
          screenWidth = 32*BLOCK,
          screenHeight = 27*BLOCK;

/**
 * Gravity consists of a uniform downforce,
 * and a gravitational acceleration
 */
float DOWN_FORCE = 2;
float ACCELERATION = 1.3;
float DAMPENING = 0.75;


/**
 * initializing means building an "empty"
 * level, which we'll 
 */
void initialize() {
  frameRate(30);
  reset();
}

void reset() {
  clearScreens();
  addScreen("Level One", new LevelOne(width, height));
  addScreen("Level Two", new LevelTwo(width, height));
  setActiveScreen("Level One");
}


/**
 * level and layer super classes
 */
class MarioLevel extends Level {
  Mario mario;
  MarioLevel(float levelWidth, float levelHeight) {
    super(levelWidth, levelHeight);
  }
  void swapForLevel(String otherLevel) {
    setActiveScreen(otherLevel);
  }
}

class MarioLayer extends LevelLayer {
  MarioLayer(Level owner) {
    super(owner); 
  }

  void addGround(String tileset, float x1, float y1, float x2, float y2) {
    TilingSprite groundline = new TilingSprite(new Sprite("graphics/backgrounds/"+tileset+"-top.gif"), x1,y1,x2,y1+16);
    addBackgroundSprite(groundline);
    TilingSprite groundfiller = new TilingSprite(new Sprite("graphics/backgrounds/"+tileset+"-filler.gif"), x1,y1+16,x2,y2);
    addBackgroundSprite(groundfiller);
    addBoundary(new Boundary(x1,y1,x2,y1));
  }
}


/**
 * First level
 */
class LevelOne extends MarioLevel {
  LevelOne(float w, float h) {
    super(w, h);
    addLevelLayer("main layer", new LevelOneLayer(this));
    setViewBox(0,0,w,h);
    // set up a mario
    mario = new Mario();
    mario.setPosition(32, height-64);
    getLevelLayer("main layer").addPlayer(mario);
  }

  void mousePressed(int mx, int my, int mb) {
    if(mb == RIGHT) { swapForLevel("Level Two"); }
  }
}

class LevelOneLayer extends MarioLayer {
  LevelOneLayer(Level owner) {
    super(owner);
    setBackgroundColor(color(0, 100, 190));
    addBackgroundSprite(new TilingSprite(new Sprite("graphics/backgrounds/sky.gif"),0,0,width,height));
    addBoundary(new Boundary(-1,0, -1,height));
    addBoundary(new Boundary(width+1,height, width+1,0));
    addGround("ground", 0,height-48, width,height);
  }
}


/**
 * Second level
 */
class LevelTwo extends MarioLevel {
  LevelTwo(float w, float h) {
    super(w, h);
    addLevelLayer("main layer", new LevelTwoLayer(this));
    setViewBox(0,0,w,h);
    // set up another mario
    mario = new Mario();
    mario.setPosition(32, height-64);
    getLevelLayer("main layer").addPlayer(mario);
  }

  void mousePressed(int mx, int my, int mb) {
    if(mb == RIGHT) { swapForLevel("Level One"); }
  }
}

class LevelTwoLayer extends MarioLayer {
  LevelTwoLayer(Level owner) {
    super(owner);
    setBackgroundColor(color(0, 0, 100));
    addBackgroundSprite(new TilingSprite(new Sprite("graphics/backgrounds/bonus.gif"),0,0,width,height));
    addBoundary(new Boundary(-1,0, -1,height));
    addBoundary(new Boundary(width+1,height, width+1,0));
    addGround("cave", 0,height-48, width,height);
  }
}


/**
 * Our dapper hero
 */
class Mario extends Player {
  
  int score = 0;
  float speed = 2;

  Mario() {
    super("Mario");
    setStates();
    handleKey('W');
    handleKey('A');
    handleKey('S');
    handleKey('D');
    setImpulseCoefficients(DAMPENING, DAMPENING);
    setForces(0, DOWN_FORCE);
    setAcceleration(0, ACCELERATION);
  }

  // make sure all states are center/bottom anchored
  void addState(State st) {
    st.sprite.anchor(CENTER, BOTTOM);
    super.addState(st);
  }  
  
  /**
   * Set up our states
   */
  void setStates() {
    // idling state
    addState(new State("idle", "graphics/mario/small/Standing-mario.gif"));

    // crouching state
    addState(new State("crouching", "graphics/mario/small/Crouching-mario.gif"));

    // running state
    addState(new State("running", "graphics/mario/small/Running-mario.gif", 1, 4));
    
    // jumping state
    State jumping = new State("jumping", "graphics/mario/small/Jumping-mario.gif");
    jumping.setDuration(15);
    addState(jumping);
    SoundManager.load(jumping, "audio/Jump.mp3");

    // crouchjumping state
    State crouchjumping = new State("crouchjumping", "graphics/mario/small/Crouching-mario.gif");
    crouchjumping.setDuration(15);
    addState(crouchjumping);
    SoundManager.load(crouchjumping, "audio/Jump.mp3");

    // default: just stand around doing nothing
    setCurrentState("idle");
  }

  /**
   * When 'fixed frame count' animations end
   * such as the jump animation, what should we do?
   */
  void handleStateFinished(State which) {
    setCurrentState("idle");
  }

  void handleInput() {
    // what do we "do"? (i.e. movement wise)
    if (active.name!="crouching" && (isKeyDown('A') || isKeyDown('D'))) {
      if (isKeyDown('A')) {
        setHorizontalFlip(true);
        addImpulse(-speed, 0);
      }
      if (isKeyDown('D')) {
        setHorizontalFlip(false);
        addImpulse(speed, 0);
      }
    }

    // if the jump key is pressed, and we're standing on something, let's jump! 
    if (active.mayChange() && isKeyDown('W') && boundaries.size()>0) {
      ignore('W');
      addImpulse(0, -35);
      if (active.name!="crouching") { setCurrentState("jumping"); }
      else { setCurrentState("crouchjumping"); }
      SoundManager.play(active);
    }

    // if we're not jumping, but left or right is pressed,
    // make sure we're using the "running" state.
    if (isKeyDown('S')) {
      if (active.name=="jumping") { setCurrentState("crouchjumping"); }
      else { setCurrentState("crouching"); }
    }

    if (active.mayChange()) {
      if (active.name!="crouching" && (isKeyDown('A') || isKeyDown('D'))) {
        setCurrentState("running");
      }
      else if (noKeysDown()) { setCurrentState("idle"); }
    }
  }
}
