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
  addScreen("MainLevel", new MainLevel(width, height));  
}

/**
 * Our "empty" level is a single layer
 * level, doing absolutely nothing.
 */
class MainLevel extends Level {
  MainLevel(float levelWidth, float levelHeight) {
    super(levelWidth, levelHeight);
    addLevelLayer("background layer", new BackgroundLayer(this));
    LayerSuperClass mainLayer = new MainLevelLayer(this);
    addLevelLayer("main layer", mainLayer);
    setViewBox(0,0,screenWidth,screenHeight);
    
    // set up Mario in the main layer
    mario = new Mario();
    mario.setPosition(32, height-64);
    mainLayer.mario = mario;
    mainLayer.addPlayer(mario);
  }
}

class LayerSuperClass extends LevelLayer {
  Mario mario;
  
  // fallthrough constructors
  LayerSuperClass(Level owner) {
    super(owner); }

  LayerSuperClass(Level owner, float w, float h, float tx, float ty, float sx, float sy) {
    super(owner,  w,h,  tx,ty,  sx,sy); }

  void addGround(String tileset, float x1, float y1, float x2, float y2) {
    TilingSprite groundline = new TilingSprite(new Sprite("graphics/backgrounds/"+tileset+"-top.gif"), x1,y1,x2,y1+16);
    addBackgroundSprite(groundline);
    TilingSprite groundfiller = new TilingSprite(new Sprite("graphics/backgrounds/"+tileset+"-filler.gif"), x1,y1+16,x2,y2);
    addBackgroundSprite(groundfiller);
    addBoundary(new Boundary(x1,y1,x2,y1));
  }

  // layer "teleport" method:
  void moveToLayer(Player p, String layerName) {
    // first remove the player from "this" layer
    removePlayer(p);
    mario = null;
    // introduce to other layer
    LayerSuperClass other = (LayerSuperClass) parent.getLevelLayer(layerName);
    other.mario = p;
    p.setPosition(64, -64);
    other.addPlayer(p);
  }
}


class BackgroundLayer extends LayerSuperClass {
  BackgroundLayer(Level owner) {
    super(owner, owner.width, owner.height, 0,0, 0.75,0.75);
    width += screenWidth;
    setBackgroundColor(color(0, 100, 190));
    addBackgroundSprite(new TilingSprite(new Sprite("graphics/backgrounds/sky_2.gif"),0,0,width,height));
    addBoundary(new Boundary(-1,0, -1,height));
    addBoundary(new Boundary(width+1,height, width+1,0));
    addGround("ground", 0, height/2, width-100, height/2+16);
  }
  
  // if mario falls off, teleport to foreground
  void draw() {
    super.draw();
    if(mario != null && mario.y>height+64) {
      moveToLayer(mario, "main layer");
    }
  }
}


class MainLevelLayer extends LayerSuperClass {
  MainLevelLayer(Level owner) {
    super(owner);
    addBackgroundSprite(new TilingSprite(new Sprite("graphics/backgrounds/sky.gif"),0,0,width,height));
    addBoundary(new Boundary(-1,0, -1,height));
    addBoundary(new Boundary(width+1,height, width+1,0));
    addGround("ground", -32,height-48, width/2-96,height);
  }

  // if mario falls off, teleport to background
  void draw() {
    super.draw();
    if(mario != null && mario.y>height+64) {
      moveToLayer(mario, "background layer");
    }
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
