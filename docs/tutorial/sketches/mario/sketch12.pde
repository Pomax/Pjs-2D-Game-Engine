final int screenWidth = 512;
final int screenHeight = 432;

float DOWN_FORCE = 2;
float ACCELERATION = 1.3;
float DAMPENING = 0.75;

void initialize() {
  frameRate(30);
  reset();
}

void reset() {
  clearScreens();
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

    // add some ground platforms, some with coins
    addGroundPlatform("ground", 928, height-224, 96, 112);
    addCoins(928,height-236,96);
    addGroundPlatform("ground", 920, height-176, 32, 64);
    addGroundPlatform("ground", 912, height-128, 128, 80);
    addCoins(912,height-140,128);
    addGroundPlatform("ground", 976, height-96, 128, 48);
    addGroundPlatform("ground", 1442, height-128, 128, 80);
    addCoins(1442,height-140,128);
    addGroundPlatform("ground", 1442+64, height-96, 128, 48);
  
    // mystery coins
    addForPlayerOnly(new DragonCoin(352,height-164));
  
    // Let's also add a koopa on one of the slides
    Koopa koopa = new Koopa(264, height-178);
    addInteractor(koopa);

    // and let's add the thing that makes us win!
    addGoal(1920, height-48);
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

  // add coins over a horizontal stretch  
  void addCoins(float x, float y, float w) {
    float step = 16, i = 0, last = w/step;
    for(i=0; i<last; i++) {
      addForPlayerOnly(new Coin(x+8+i*step,y));
    }
  }

  // And finally, the end of the level!
  void addGoal(float xpos, float hpos) {
    hpos += 1;
    // background post
    Sprite goal_b = new Sprite("graphics/assorted/Goal-back.gif");
    goal_b.align(CENTER, BOTTOM);
    goal_b.setPosition(xpos, hpos);
    addBackgroundSprite(goal_b);
    // foreground post
    Sprite goal_f = new Sprite("graphics/assorted/Goal-front.gif");
    goal_f.align(CENTER, BOTTOM);
    goal_f.setPosition(xpos+32, hpos);
    addForegroundSprite(goal_f);
    // the finish line rope
    addForPlayerOnly(new Rope(xpos, hpos-16));
  }

  void draw() {
    super.draw();
    viewbox.track(parent, mario);
  }
}

class Mario extends Player {
  int score = 0;
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
    dead.setDuration(15);
    addState(dead);   
    
    State jumping = new State("jumping", "graphics/mario/small/Jumping-mario.gif");
    jumping.setDuration(15);
    addState(jumping);

    State won = new State("won", "graphics/mario/small/Standing-mario.gif");
    won.setDuration(15);
    addState(won);

    setCurrentState("idle");    
  }
  void handleStateFinished(State which) {
    if(which.name == "dead" || which.name == "won") {
      removeActor();
      reset();
    } else {
      setCurrentState("idle");
    }
  }
  void handleInput() {
    // we don't handle any input when we're dead~
    if(active.name=="dead" || active.name=="won") return;
    
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
  /**
   * What happens when we get pickups?
   */
  void pickedUp(Pickup pickup) {
    // we got some points
    if (pickup.name=="Regular coin") {
      score++;
    }
    // we got big points
    else if (pickup.name=="Dragon coin") {
      score+=100;
    }
    // we won!
    else if (pickup.name=="Finish line") {
      setCurrentState("won");
    }
  }

  
  /**
   * What happens when we touch another actor?
   */
  void overlapOccurredWith(Actor other, float[] direction) {
    if (other instanceof Koopa) {
      Koopa koopa = (Koopa) other;
      float angle = direction[2];

      // We bopped a koopa on the head!
      float tolerance = radians(75);
      if (PI/2 - tolerance <= angle && angle <= PI/2 + tolerance) {
        koopa.squish();
        stop(0,0);
        setImpulse(0, -30);
        setCurrentState("jumping");
      }

      // Oh no! We missed and touched a koopa!
      else { die(); }
    }
  }

  /**
   * When we die, we need to go in the funky "oh no we lost~" dance dive.
   */
  void die() {
    setCurrentState("dead");
    setInteracting(false);
    addImpulse(0,-30);
    setForces(0,3);
  }
  
}

/**
 * All pickups in Mario may move, and if
 * they do, they will bounce when hitting
 * a clean boundary.
 */
class MarioPickup extends Pickup {
  MarioPickup(String name, String spritesheet, int rows, int columns, float x, float y, boolean visible) {
    super(name, spritesheet, rows, columns, x, y, visible);
  }
  void gotBlocked(Boundary b, float[] intersection) {
    if (intersection[0]-x==0 && intersection[1]-y==0) {
      fx = -fx;
      active.sprite.flipHorizontal();
    }
  }
}

/**
 * A regular coin
 */
class Coin extends MarioPickup {
  Coin(float x, float y) {
    super("Regular coin", "graphics/assorted/Regular-coin.gif", 1, 4, x, y, true);
  }
}


/**
 * A dragon coin!
 */
class DragonCoin extends MarioPickup {
  DragonCoin(float x, float y) {
    super("Dragon coin", "graphics/assorted/Dragon-coin.gif", 1, 10, x, y, true);
  }
}


/**
 * The finish line is also a pickup,
 * and will trigger the "clear" state
 * for the level when picked up.
 */
class Rope extends MarioPickup {
  Rope(float x, float y) {
    super("Finish line", "graphics/assorted/Goal-slider.gif", 1, 1, x, y, true);
    Sprite s = getState("Finish line").sprite;
    s.align(LEFT, TOP);
    s.setNoRotation(true);
    s.addPathLine(0, 0, 1, 1, 0, 0, -116, 1, 1, 0, 50);
    s.addPathLine(0, -116, 1, 1, 0, 0, 0, 1, 1, 0, 50);
    s.setLooping(true);
  }
}


/**
 * Our main enemy
 */
class Koopa extends Interactor {

  Koopa(float x, float y) {
    super("Koopa Trooper");
    setStates();
    setForces(-0.25, DOWN_FORCE);    
    setImpulseCoefficients(DAMPENING, DAMPENING);
    setPosition(x,y);
  }
  
  /**
   * Set up our states
   */
  void setStates() {
    // walking state
    State walking = new State("idle", "graphics/enemies/Red-koopa-walking.gif", 1, 2);
    walking.setAnimationSpeed(0.12);
    addState(walking);
    
    // if we get squished, we first get naked...
    State naked = new State("naked", "graphics/enemies/Naked-koopa-walking.gif", 1, 2);
    naked.setAnimationSpeed(0.12);
    addState(naked);
    
    setCurrentState("idle");
  }
  
  /**
   * when we hit a vertical wall, we want our
   * koopa to reverse direction
   */
  void gotBlocked(Boundary b, float[] intersection) {
    if (b.x==b.xw) {
      fx = -fx;
      setHorizontalFlip(fx > 0);
    }
  }
  
  void squish() {
    // do we have our shell? Then we only get half-squished.
    if (active.name != "naked") {
      setCurrentState("naked");
      return;
    }
    
    // no shell... this koopa is toast.
    removeActor();
  }
}
