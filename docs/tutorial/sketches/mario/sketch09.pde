final int screenWidth = 512;
final int screenHeight = 432;

float DOWN_FORCE = 2;
float ACCELERATION = 1.3;
float DAMPENING = 0.75;

void initialize() {
  frameRate(30);
  addScreen("level", new MarioLevel(4*width, height));
}

class MarioLevel extends Level {
  MarioLevel(float levelWidth, float levelHeight) {
    super(levelWidth, levelHeight);
    setViewBox(0,0,screenWidth,screenHeight);
    addLevelLayer("background", new BackgroundLayer(this));
    addLevelLayer("layer", new MarioLayer(this));
  }
}

class BackgroundLayer extends LevelLayer {
  BackgroundLayer(Level owner) {
    super(owner, owner.width, owner.height, 0,0, 0.75,0.75);
    setBackgroundColor(color(0, 100, 190));
    addBackgroundSprite(new TilingSprite(new Sprite("graphics/backgrounds/sky_2.gif"),0,0,width,height));
  }
}

class MarioLayer extends LevelLayer {
  Mario mario;
  MarioLayer(Level owner) {
    super(owner);
    addBackgroundSprite(new TilingSprite(new Sprite("graphics/backgrounds/sky.gif"),0,0,width,height));
    addBoundary(new Boundary(0,height-48,width,height-48));
    addBoundary(new Boundary(-1,0, -1,height));
    addBoundary(new Boundary(width+1,height, width+1,0));
    showBoundaries = true;
    mario = new Mario(32, height-64);
    addPlayer(mario);

    // add base ground
    addGround("ground", -32,height-48, width+32,height);

    // add a few slanted hills
    addSlant(256, height-48);
    addSlant(1300, height-48);
    addSlant(1350, height-48);

    // add some ground platforms    
    addGroundPlatform("ground", 928, height-224, 96, 112);
    addGroundPlatform("ground", 920, height-176, 32, 64);
    addGroundPlatform("ground", 912, height-128, 128, 80);
    addGroundPlatform("ground", 976, height-96, 128, 48);
    addGroundPlatform("ground", 1442, height-128, 128, 80);
    addGroundPlatform("ground", 1442+64, height-96, 128, 48);  
  }

  /**
   * Add some ground.
   */
  void addGround(String tileset, float x1, float y1, float x2, float y2) {
    TilingSprite groundline = new TilingSprite(new Sprite("graphics/backgrounds/"+tileset+"-top.gif"), x1,y1,x2,y1+16);
    addBackgroundSprite(groundline);
    TilingSprite groundfiller = new TilingSprite(new Sprite("graphics/backgrounds/"+tileset+"-filler.gif"), x1,y1+16,x2,y2);
    addBackgroundSprite(groundfiller);
    addBoundary(new Boundary(x1,y1,x2,y1));
  }  

  /**
   * This creates the raised, angled sticking-out-ground bit.
   * it's actually a sprite, not a rotated generated bit of ground.
   */
  void addSlant(float x, float y) {
    Sprite groundslant = new Sprite("graphics/backgrounds/ground-slant.gif");
    groundslant.align(LEFT, BOTTOM);
    groundslant.setPosition(x, y);
    addBackgroundSprite(groundslant);
    addBoundary(new Boundary(x, y + 48 - groundslant.height, x + 48, y - groundslant.height));
  }

  /**
   * Add a platform with solid ground underneath.
   */
  void addGroundPlatform(String tileset, float x, float y, float w, float h) {
    // top layer
    Sprite lc = new Sprite("graphics/backgrounds/"+tileset+"-corner-left.gif");
    lc.align(LEFT, TOP);
    lc.setPosition(x, y);
    Sprite tp = new Sprite("graphics/backgrounds/"+tileset+"-top.gif");
    Sprite rc = new Sprite("graphics/backgrounds/"+tileset+"-corner-right.gif");
    rc.align(LEFT, TOP);
    rc.setPosition(x+w-rc.width, y);
    TilingSprite toprow = new TilingSprite(tp, x+lc.width, y, x+(w-rc.width), y+tp.height);

    addBackgroundSprite(lc);
    addBackgroundSprite(toprow);
    addBackgroundSprite(rc);

    // sides/filler
    TilingSprite sideleft  = new TilingSprite(new Sprite("graphics/backgrounds/"+tileset+"-side-left.gif"),  x,            y+tp.height, x+lc.width,     y+h);
    TilingSprite filler    = new TilingSprite(new Sprite("graphics/backgrounds/"+tileset+"-filler.gif"),     x+lc.width,   y+tp.height, x+(w-rc.width), y+h);
    TilingSprite sideright = new TilingSprite(new Sprite("graphics/backgrounds/"+tileset+"-side-right.gif"), x+w-rc.width, y+tp.height, x+w,            y+h);

    addBackgroundSprite(sideleft);
    addBackgroundSprite(filler);
    addBackgroundSprite(sideright);

    // boundary to walk on
    addBoundary(new Boundary(x, y, x+w, y));
  }
  
  void draw() {
    super.draw();
    viewbox.track(parent, mario);
  }
}

class Mario extends Player {
  float speed = 2;
  Mario(float x, float y) {
    super("Mario");
    setupStates();
    setPosition(x,y);
    handleKey('W');
    handleKey('A');
    handleKey('D');
    setForces(0,DOWN_FORCE);
    setAcceleration(0,ACCELERATION);
    setImpulseCoefficients(DAMPENING,DAMPENING);
  }
  void setupStates() {
    addState(new State("idle", "graphics/mario/small/Standing-mario.gif"));
    addState(new State("running", "graphics/mario/small/Running-mario.gif", 1, 4));

    State dead = new State("dead", "graphics/mario/small/Dead-mario.gif", 1, 2);
    dead.setAnimationSpeed(0.25);
    dead.setDuration(100);
    addState(dead);   
    
    State jumping = new State("jumping", "graphics/mario/small/Jumping-mario.gif");
    jumping.setDuration(15);
    addState(jumping);

    setCurrentState("idle");    
  }
  void handleStateFinished(State which) {
    setCurrentState("idle");
  }
  void handleInput() {
    if(isKeyDown('A') || isKeyDown('D')) {
      if (isKeyDown('A')) {
        setHorizontalFlip(true);
        addImpulse(-speed, 0);
      }
      if (isKeyDown('D')) {
        setHorizontalFlip(false);
        addImpulse(speed, 0);
      }
    }

    if(isKeyDown('W') && active.name!="jumping" && boundaries.size()>0) {
      addImpulse(0,-35);
      setCurrentState("jumping");
    }
    
    if (active.mayChange()) {
      if(isKeyDown('A') || isKeyDown('D')) {
        setCurrentState("running");
      }
      else { setCurrentState("idle"); }
    }
  }  
  
}