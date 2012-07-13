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

/**
 * Reset the entire game
 */
void reset() {
  clearScreens();
  addScreen("MainLevel", new MainLevel(4*width, height));  
}


/**
 * Our "empty" level is a single layer
 * level, doing absolutely nothing.
 */
class MainLevel extends Level {
  MainLevel(float levelWidth, float levelHeight) {
    super(levelWidth, levelHeight);
    addLevelLayer("background layer", new MainBackgroundLayer(this));
    addLevelLayer("main layer", new MainLevelLayer(this));
    setViewBox(0,0,screenWidth,screenHeight);
    // And of course some background music!
    SoundManager.load(this, "audio/bg/Overworld.mp3");
    SoundManager.play(this);
  }
}


/**
 * Our main level layer has a background
 * color, and nothing else.
 */
class MainBackgroundLayer extends LevelLayer {
  Mario mario;
  MainBackgroundLayer(Level owner) {
    super(owner, owner.width, owner.height, 0,0, 0.75,0.75);
    setBackgroundColor(color(0, 100, 190));
    addBackgroundSprite(new TilingSprite(new Sprite("graphics/backgrounds/sky_2.gif"),0,0,width,height));
  }
  void draw() {
    super.draw();
  }
}


/**
 * Our main level layer has a background
 * color, and nothing else.
 */
class MainLevelLayer extends LevelLayer {
  Mario mario;
  
  MainLevelLayer(Level owner) {
    super(owner);
    //setBackgroundColor(color(0,130,255));
    addBackgroundSprite(new TilingSprite(new Sprite("graphics/backgrounds/sky.gif"),0,0,width,height));

    // set up Mario!
    mario = new Mario();
    mario.setPosition(32, height-64);
    addPlayer(mario);
    
    // add a few slanted hills
    addSlant(256, height-48);
    addSlant(1300, height-48);
    addSlant(1350, height-48);

    // we don't want mario to walk off the level,
    // so let's add some side walls
    addBoundary(new Boundary(-1,0, -1,height));
    addBoundary(new Boundary(width+1,height, width+1,0));

    // add general ground
    addGround("ground", -32,height-48, -32 + 17*32,height);
    addBoundary(new Boundary(-32 + 17*32,height-48,-32 + 17*32,height));

    addInteractor(new Muncher(521, height-8));
    addInteractor(new Muncher(536, height-8));
    addInteractor(new Muncher(552, height-8));
    addInteractor(new Muncher(567, height-8));

    addBoundary(new Boundary(-31 + 19*32,height,-31 + 19*32,height-48));
    addGround("ground", -31 + 19*32,height-48, width+32,height);

    // add some ground platforms    
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
    
    // add lots of just-in-time triggers
    addTriggers();
    
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
  
  // In order to effect "just-in-time" sprite placement,
  // we set up some trigger regions.
  void addTriggers() {
    addTrigger(new KoopaTrigger(412,0,5,height, 350, height-64, -0.2, 0));
    addTrigger(new KoopaTrigger(562,0,5,height, 350, height-64, -0.2, 0));
    addTrigger(new KoopaTrigger(916,0,5,height, 350, height-64, -0.2, 0));
  }

  void draw() {
    super.draw();
    viewbox.track(parent, mario);
    // just in case!
    if(mario!=null && mario.active != null && mario.active.name!="dead" && mario.y>height) {
      reset();
    }
  }
}


//////////////
//  ACTORS  //
//////////////


/**
 * Our dapper mustachioed hero
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
  
  /**
   * Set up our states
   */
  void setStates() {
    // idling state
    addState(new State("idle", "graphics/mario/small/Standing-mario.gif"));

    // running state
    addState(new State("running", "graphics/mario/small/Running-mario.gif", 1, 4));

    // dead state O_O
    State dead = new State("dead", "graphics/mario/small/Dead-mario.gif", 1, 2);
    dead.setAnimationSpeed(0.25);
    dead.setDuration(100);
    addState(dead);   
    SoundManager.load(dead, "audio/Dead mario.mp3");
    
    // jumping state
    State jumping = new State("jumping", "graphics/mario/small/Jumping-mario.gif");
    jumping.setDuration(15);
    addState(jumping);
    SoundManager.load(jumping, "audio/Jump.mp3");

    // victorious state!
    State won = new State("won", "graphics/mario/small/Standing-mario.gif");
    won.setDuration(240);
    addState(won);

    // default: just stand around doing nothing
    setCurrentState("idle");
  }
  
  /**
   * Handle input
   */
  void handleInput() {
    // we don't handle any input when we're dead~
    if(active.name=="dead" || active.name=="won") return;
    
    // what do we "do"? (i.e. movement wise)
    if(isKeyDown('A') || isKeyDown('D')) {
      if (isKeyDown('A')) {
        // when we walk left, we need to flip the sprite
        setHorizontalFlip(true);
        // walking left means we get a negative impulse along the x-axis:
        addImpulse(-speed, 0);
        // and we set the viewing direction to "left"
        setViewDirection(-1, 0);
      }
      if (isKeyDown('D')) {
        // when we walk right, we need to NOT flip the sprite =)
        setHorizontalFlip(false);
        // walking right means we get a positive impulse along the x-axis:
        addImpulse(speed, 0);
        // and we set the viewing direction to "right"
        setViewDirection(1, 0);
      }
    }
    
    // if the jump key is pressed, and we're standing on something,
    // let's jump! 
    if(isKeyDown('W') && active.name!="jumping" && boundaries.size()>0) {
      // generate a massive impulse upward
      addImpulse(0,-35);
      // and make sure we look like we're jumping, too
      setCurrentState("jumping");
      SoundManager.play(active);
    }
    
    // and what do we look like when we do this?
    if (active.mayChange())
    {
      // if we're not jumping, but left or right is pressed,
      // make sure we're using the "running" state.
      if(isKeyDown('A') || isKeyDown('D')) {
        setCurrentState("running");
      }
      
      // if we're not actually doing anything,
      // then we change the state to "idle"
      else {
        setCurrentState("idle");
      }
    }
  }
  
  /**
   * When 'fixed frame count' animations end
   * such as the jump animation, what should we do?
   */
  void handleStateFinished(State which) {
    if(which.name == "dead" || which.name == "won") {
      removeActor();
      reset();
    } else {
      setCurrentState("idle");
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
    // stop background music!
    SoundManager.stop(getLevelLayer().getLevel());
    // play sad music =(
    SoundManager.play(active);
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
}


/**
 * Our main enemy in this game
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
    SoundManager.load(walking, "audio/Squish.mp3");
    addState(walking);
    
    // if we get squished, we first get naked...
    State naked = new State("naked", "graphics/enemies/Naked-koopa-walking.gif", 1, 2);
    naked.setAnimationSpeed(0.12);
    SoundManager.load(naked, "audio/Squish.mp3");
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
    SoundManager.play(active);

    // do we have our shell? Then we only get half-squished.
    if (active.name != "naked") {
      setCurrentState("naked");
      return;
    }
    
    // no shell... this koopa is toast.
    removeActor();
  }
}


/**
 * The muncher plant. To touch it is to lose.
 */
class Muncher extends Interactor {

  Muncher(float x, float y) {
    super("Muncher");
    setPosition(x,y);
    setupStates();
  }

  void setupStates() {
    State munch = new State("munch","graphics/enemies/Muncher.gif", 1, 2);
    munch.setAnimationSpeed(0.20);
    addState(munch);
  }

  void overlapOccurredWith(Actor other, float[] overlap) {
    super.overlapOccurredWith(other, overlap);
    if (other instanceof Mario) {
      ((Mario)other).die();
    }
  }
}


/////////////////
//   PICKUPS   //
/////////////////


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
    SoundManager.load(this, "audio/Coin.mp3");
  }
  void pickedUp() { 
    SoundManager.play(this);
  }
}


/**
 * A dragon coin!
 */
class DragonCoin extends MarioPickup {
  DragonCoin(float x, float y) {
    super("Dragon coin", "graphics/assorted/Dragon-coin.gif", 1, 10, x, y, true);
    SoundManager.load(this, "audio/Dragon coin.mp3");
  }
  void pickedUp() { 
    SoundManager.play(this);
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
    SoundManager.load(this, "audio/bg/Course-clear.mp3");
  }

  void pickedUp() {
    // stop background music!
    SoundManager.stop(getLevelLayer().getLevel());
    // play victory music!
    SoundManager.play(this);
  }
}


////////////////
//  TRIGGERS  //
////////////////


/**
 * triggers a koopa trooper 350px to the right
 */
class KoopaTrigger extends Trigger {
  float kx, ky, fx, fy;
  KoopaTrigger(float x, float y, float w, float h, float _kx, float _ky, float _fx, float _fy) {
    super("koopa", x, y, w, h);
    kx = _kx;
    ky = _ky;
    fx = _fx;
    fy = _fy;
  }
  void run(LevelLayer layer, Actor actor, float[] intersection) {
    Koopa k = new Koopa(x+kx, ky);
    if (fx>0) { 
      k.setHorizontalFlip(true);
    }
    layer.addInteractor(k);
    // remove this trigger so that it's not repeated
    removeTrigger();
  }
}