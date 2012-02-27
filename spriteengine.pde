// ====== LET'S GET OUR NINTENDO ON! ======

// This value determines how much we "slide" when we walk
float DAMPENING = 0.75;

// This value determines how much 'gravity' we experience
float DOWN_FORCE = 0.7;

// This value determines how strong gravity's hold on us is.
// The higher the value, the more speed we pick up as we fall.
float ACCELERATION = 1.3;

// and this is the level we'll be playing.
Level level;

// boilerplate
void setup() {
  size(512,432);
  frameRate(24);
  // It is essential that this is called
  // before any sprites are made:
  SpriteMapHandler.setSketch(this);
  level = new TestLevel(width, height); }

// Render mario in glorious canvas definition
void draw() { level.draw(); }

// pass-through keyboard events
void keyPressed() { level.keyPressed(key,keyCode); }
void keyReleased() { level.keyReleased(key, keyCode); }
void mousePressed() { level.mousePressed(mouseX, mouseY); }


// ========== TEST LEVEL CODE ============


/**
 * The test implementaiton of the Level class
 * models the first normal level of Super Mario
 * World, "Yoshi's Island 1". With some liberties
 * taken, because this is a test.
 */
class TestLevel extends Level {
  // local handle for the mario sprite
  Player mario;

  /**
   * Test level implementation
   */
  TestLevel(float w, float h)
  {
    super(w, h);
    setBackground();
    addGround();
    addBushes();
    addCloudPlatforms();
    addCoins();
    addDragonCoins();
    addFlyingKoopas();
  }

  // the background is a sprite
  void setBackground() {
    Sprite bgsprite = new Sprite("graphics/backgrounds/sky.gif");
    bgsprite.align(RIGHT, TOP);
    TilingSprite backdrop = new TilingSprite(bgsprite, 0, 0, width, height);
    addStaticSpriteBG(backdrop);
  }

  // "ground" parts of the level
  void addGround() {
    // top of the ground
    Sprite groundsprite = new Sprite("graphics/backgrounds/ground-top.gif");
    TilingSprite groundline = new TilingSprite(groundsprite, 0, height-40, 2*width, height - 40 + groundsprite.height);
    addStaticSpriteBG(groundline);

    // ground filler
    TilingSprite groundfiller = new TilingSprite(new Sprite("graphics/backgrounds/ground-filler.gif"), 0, height-40 + groundsprite.height, 2*width, height);
    addStaticSpriteBG(groundfiller);

    // the angled bit of sticking-out-ground
    Sprite groundslant = new Sprite("graphics/backgrounds/ground-slant.gif");
    groundslant.align(RIGHT,TOP);
    groundslant.setPosition(width/2, height - groundslant.height - 48);
    addStaticSpriteBG(groundslant);

    // ground boundaries
    boundaries.add(new Boundary(-20,height-48,width+20,height-48));
    boundaries.add(new Boundary(width/2, height - groundslant.height, width/2 + 48, height - groundslant.height - 48));
  }

  // add some mario-style bushes
  void addBushes() {
    // one bush, composed of four segmetns (sprites 1, 3, 4 and 5)
    int[] bush = {1, 3, 4, 5};
    for(int i=0, xpos=0, end=bush.length; i<end; i++) {
      Sprite sprite = new Sprite("graphics/backgrounds/bush-0"+bush[i]+".gif");
      xpos += sprite.width;
      sprite.align(CENTER,BOTTOM);
      sprite.setPosition(width/4.4 + xpos, height-48);
      addStaticSpriteFG(sprite); }
    // two bush, composed of eight segments
    bush = new int[]{1, 2, 4, 2, 3, 4, 2, 5};
    for(int i=0, xpos=0, end=bush.length; i<end; i++) {
      Sprite sprite = new Sprite("graphics/backgrounds/bush-0"+bush[i]+".gif");
      xpos += sprite.width;
      sprite.align(CENTER,BOTTOM);
      sprite.setPosition(3*width/4 + xpos, height-48);
      addStaticSpriteFG(sprite); }
  }

  // clouds platforms!
  void addCloudPlatforms() {
    addBoundary(new Boundary(54 +   0, 96 +   0, 105 +   0, 96 +   0));
    addBoundary(new Boundary(54 + 224, 96 +  48, 105 + 224, 96 +  48));
    addBoundary(new Boundary(54 + 336, 96 +  32, 105 + 336, 96 +  32));
    addBoundary(new Boundary(54 + 256, 96 + 192, 105 + 256, 96 + 192));
    addBoundary(new Boundary(54 + 336, 96 + 208, 105 + 336, 96 + 208));
    addBoundary(new Boundary(54 + 138, 96 + 144, 105 + 112, 96 + 144));
    addBoundary(new Boundary(54 + 186, 96 + 160, 105 + 160, 96 + 160));
    addBoundary(new Boundary(54 + 330, 96 + 256, 105 + 322, 96 + 256));
  }

  // add some coins
  void addCoins() {
    addCoin(80,96);
    addCoin(80 + 224, 96 +  48);
    addCoin(80 + 336, 96 +  32);
    addCoin(80 + 256, 96 + 192);
    addCoin(80 + 336, 96 + 208);
    addCoin(80 + 126, 96 + 144);
  }

  // convenient shortcut method for placing three coins at once
  void addCoin(float x, float y) {
    addForPlayerOnly(new Coin(x-16, y - 40));
    addForPlayerOnly(new Coin(   x, y - 40));
    addForPlayerOnly(new Coin(x+16, y - 40));
  }

  // add some mysterious coins
  void addDragonCoins() {
    addForPlayerOnly(new DragonCoin(116, 280));
    addForPlayerOnly(new DragonCoin(140, 298));
    addForPlayerOnly(new DragonCoin(180, 330));
    addForPlayerOnly(new DragonCoin(204, 298));
  }

  // add some flying koopas
  void addFlyingKoopas() {
    for(int i=0; i<3; i++) {    
      FlyingKoopa fk = new FlyingKoopa(150,175 + i*30);
      fk.active.sprite.setPathOffset(i*30);
      addInteractor(fk);
    }
  }

  /**
   * Render mario in glorious canvas definition
   */
  void draw() {
    // make sure we always have a Mario!
    if(players.size()==0) {
      mario = new Mario();
      mario.setPosition(width/2,height/2);
      addPlayer(mario); }

    // blue background color
    background(0,100,190);

    // draw the level content
    super.draw();

    // wrap-around for the mario sprite
    if(mario.x<0) mario.setPosition(width,mario.y);
    if(mario.x>width) mario.setPosition(0,mario.y);
  }

  /**
   * For fun, let's add some koopa troopers
   * every time we click on the screen!
   */
  void mousePressed(int mx, int my) {
    if(mouseButton == LEFT) {
      Koopa koopa = new Koopa(mx, my);
      koopa.addForces(-0.2,0);
      addInteractor(koopa); }
    else if(mouseButton == RIGHT) {
      addForPlayerOnly(new Mushroom(mx, my));
    }
  }
}


// ========== TEST ACTOR: MARIO ============


/**
 * Mario, that lovable, portly, moustachioed man.
 */
class Mario extends Player {

  // every 'step' has an impulse of 1.3
  float speedStep = 1.3;

  // jumping uses an impulse 19 times that of a step
  float speedHeight = 21;

  /**
   * The Mario constructor
   */
  Mario() {
    super("Mario", DAMPENING, DAMPENING);
    setForces(0, DOWN_FORCE);
    setAcceleration(0, ACCELERATION);
    setupStates();
  }

  /**
   * Set up a number of states for Mario to be in.
   */
  void setupStates() {
    // Load mario from his "small" sprite set, for now.
    String sizeSet = "small";

    // when not moving
    State standing = new State("standing","graphics/mario/"+sizeSet+"/Standing-mario.gif");
    standing.sprite.align(CENTER, BOTTOM);
    addState(standing);

    // when either running right or left
    State running = new State("running","graphics/mario/"+sizeSet+"/Running-mario.gif",1,4);
    running.sprite.align(CENTER, BOTTOM);
    running.sprite.setAnimationSpeed(0.75);
    addState(running);

    // when [down] is pressed
    State crouching = new State("crouching","graphics/mario/"+sizeSet+"/Crouching-mario.gif");
    crouching.sprite.align(CENTER, BOTTOM);
    addState(crouching);

    // when [up] is pressed
    State looking = new State("looking","graphics/mario/"+sizeSet+"/Looking-mario.gif");
    looking.sprite.align(CENTER, BOTTOM);
    addState(looking);

    // when pressing the A (jump) button
    State jumping = new State("jumping","graphics/mario/"+sizeSet+"/Jumping-mario.gif");
    jumping.sprite.align(CENTER, BOTTOM);
    jumping.sprite.addPathLine(0,0,1,1,0,  0,0,1,1,0,  24);
    addState(jumping);

    // when pressing the A button while crouching
    State crouchjumping = new State("crouchjumping","graphics/mario/"+sizeSet+"/Crouching-mario.gif");
    crouchjumping.sprite.align(CENTER, BOTTOM);
    crouchjumping.sprite.addPathLine(0,0,1,1,0,  0,0,1,1,0,  24);
    addState(crouchjumping);

    // when pressing the B (shoot) button
    State spinning = new State("spinning","graphics/mario/"+sizeSet+"/Spinning-mario.gif",1,4);
    spinning.sprite.align(CENTER, BOTTOM);
    spinning.sprite.addPathLine(0,0,1,1,0,  0,0,1,1,0,  24);
    addState(spinning);

    // if we mess up, we die =(
    State dead = new State("dead","graphics/mario/"+sizeSet+"/Dead-mario.gif",1,2);
    dead.sprite.align(CENTER, BOTTOM);
    dead.sprite.setNoRotation(true);
    dead.sprite.setLooping(false);
    dead.sprite.addPathCurve(0,0,1,1,0,
                             0,-20,
                             0,0,
                             0,300,1,1,0,  24,1);
    addState(dead);

    // Finally, we make sure to start off in the "standing" state
    setCurrentState("standing");
  }

  /**
   * We need to be able to control Mario, so let's
   * define his behaviour based on user input!
   */
  void handleInput() {

    // When the left or right key is presed, we
    // should run. Unless we're stuck in a state
    // that locks us in our place:
    if (active.name != "crouching" && active.name != "looking") {
      if (keyDown[LEFT]) {
        // when we walk left, we need to flip the sprite
        setHorizontalFlip(true);
        // walking left means we get a negative impulse along the x-axis:
        addImpulse(-speedStep, 0);
      }
      if (keyDown[RIGHT]) {
        // when we walk right, we need to NOT flip the sprite =)
        setHorizontalFlip(false);
        // walking right means we get a positive impulse along the x-axis:
        addImpulse( speedStep, 0);
      }
    }

    // Because some states will not allow use to change,
    // such as jump animations, we check whether we're
    // allowed to change our state before we check keys.
    if(active.mayChange())
    {
      // The jump button is pressed! Should we jump? How do we jump?
      if (keyDown[BUTTON_A] && boundary!=null) {
        if (active.name != "jumping" && active.name != "crouchjumping" && active.name != "spinning") {
          // first off, jumps may not auto-repeat, so we lock the jump button
          ignore(BUTTON_A);
          // make sure we unglue ourselves from the platform we're standing on:
          detach();
          // then generate a massive impulse upward:
          addImpulse(0,speedHeight*-speedStep);
          // now, if we're crouching, we need to crouch-jump.
          // Otherwise, we can jump normally.
          if (active.name == "crouching") { setCurrentState("crouchjumping"); }
          else { setCurrentState("jumping"); }
        }
      }

      // The shoot button is pressed! When we don't have a shooty power-up,
      // this makes Mario spin-jump. But should we? And How?
      else if (keyDown[BUTTON_B] && boundary!=null) {
        if (active.name != "jumping" && active.name != "crouchjumping" && active.name != "spinning") {
          // first off, shooting and spin jumping may not auto-repeat, so we lock the shoot button
          ignore(BUTTON_B);
          // make sure we unglue ourselves from the platform we're standing on:
          detach();
          // then generate a massive impulse upward:
          addImpulse(0,speedHeight*-speedStep);
          // and then make sure we spinjump, rather than jump normally
          setCurrentState("spinning");
        }
      }
      // The down button is pressed: crouch
      else if (keyDown[DOWN]) {
        setCurrentState("crouching");
      }
      // The up button is pressed: look up
      else if (keyDown[UP]) {
        setCurrentState("looking");
      }
      // The left and/or right buttons are pressed: run!
      else if (keyDown[LEFT] || keyDown[RIGHT]) {
        setCurrentState("running");
      }
      // okay, nothing's being pressed. Let's just stand there.
      else { setCurrentState("standing"); }
    }
  }

  /**
   * If Mario loses, remove him from the level.
   */
  void handleStateFinished(State which) {
    if(which.name == "dead") {
      removeActor();
    }
  }

  /**
   * When Mario touches down on a platform,
   * which state should he switch to?
   */
  void attachTo(Boundary boundary) {
    super.attachTo(boundary);
    // After crouch-jumping, Mario should be crouching
    if(active.name=="crouchjump") {
      setCurrentState("crouching");
    }
    // after other jumps, he should be standing.
    else {
      setCurrentState("standing");
    }
  }

  /**
   * What happens when we touch another actor?
   */
  void overlapOccuredWith(Actor other, float[] direction) {
    if(other instanceof Koopa) {
      Koopa koopa = (Koopa) other;
      float angle = direction[2];

      // We bopped a koopa on the head!
      float tolerance = radians(75);
      if(PI/2 - tolerance <= angle && angle <= PI/2 + tolerance) {
        boolean shouldJump = koopa.squish();
        if(shouldJump) {
          setImpulse(0,ACCELERATION*speedHeight*-speedStep);
          if(active.name!="spinning") {
            setCurrentState("jumping");
          }
        }
      }

      // Oh no! We missed and touched a koopa!
      else {
        setInteracting(false);
        setCurrentState("dead");
      }
    }
  }

  /**
   * What happens when we get pickups?
   */
  void pickedUp(Pickup pickup) {
    if(pickup.name=="Regular coin") {
      // increase our score
    }
    else if(pickup.name=="Dragon coin") {
      // increase our secret dragon score
    }
    else if(pickup.name=="Mushroom") {
      // become big!
      powerUp();
    }
  }

  /**
   * This is where we must schedule an actor replacement
   */
  void powerUp() {
    // ... code goes here...
  }
}


// ========== TEST ACTOR: KOOPA ============


/**
 * A red koopa trooper actor
 */
class Koopa extends Interactor {

  /**
   * The constructor for the koopa trooper
   * is essentially the same as for Mario.
   */
  Koopa(int mx, int my) {
    super("Red koopa", DAMPENING, DAMPENING);
    setPosition(mx, my);
    setForces(0, DOWN_FORCE);
    setAcceleration(0, ACCELERATION);
    setupStates();
  }

  /**
   * So, what can koopa troopers do?
   */
  void setupStates() {
    // when walking around
    State walking = new State("walking","graphics/enemies/Red-koopa-walking.gif",1,2);
    walking.sprite.align(CENTER, BOTTOM);
    walking.sprite.setAnimationSpeed(0.25);
    addState(walking);

    // when just standing, doing nothing
    State standing = new State("standing","graphics/enemies/Red-koopa-standing.gif",1,2);
    standing.sprite.align(CENTER, BOTTOM);
    addState(standing);

    // if we get squished, we first get naked...
    State naked = new State("naked","graphics/enemies/Naked-koopa-walking.gif",1,2);
    naked.sprite.setAnimationSpeed(0.25);
    naked.sprite.align(CENTER, BOTTOM);
    addState(naked);

    // if we get squished again, we die!
    State dead = new State("dead","graphics/enemies/Dead-koopa.gif");
    dead.sprite.align(CENTER, BOTTOM);
    dead.sprite.addPathLine(0,0,1,1,0,  0,0,1,1,0,  12);
    dead.sprite.setLooping(false);
    addState(dead);

    // by default, the koopa will be walking
    setCurrentState("walking");
  }

  /**
   * Mario squished us! O_O
   *
   * Should we just lose our shell, or have we
   * been properly squished dead?
   */
  boolean squish() {
    // if we're scheduled for removal,
    // don't do anything.
    if(remove) return false;

    // We're okay, we just lost our shell.
    if(active.name != "naked" && active.name != "dead") {
      setCurrentState("naked");
      // mario should jump after trying to squish us
      return true;
    }

    // Ohnoes! we've been squished properly!
    // make sure we stop moving forward
    setForces(0,0);
    setInteracting(false);
    setCurrentState("dead");
    // mario should not jump after deadifying us
    return true;
  }

  /**
   * While we don't let players control koopa troopers... we could!
   */
  void handleInput() {}

  /**
   * "when state finishes" behaviour: when the
   * "blargh, I am dead!" state is done, we need
   * to remove this koopa from the game.
   */
  void handleStateFinished(State which) {
    if(which.name=="dead") {
      removeActor();
    }
  }
}

/**
 * A flying red koopa trooper actor
 */
class FlyingKoopa extends Koopa {
  // are we flying or not?
  boolean flying = true;
  
  /**
   * The constructor for the koopa trooper
   * is essentially the same as for Mario.
   */
  FlyingKoopa(int mx, int my) { 
    super(mx,my); 
    setForces(0,0);
    setAcceleration(0,0);
  }

  /**
   * So, what can koopa troopers do?
   */
  void setupStates() {
    super.setupStates();
    
    // when walking around
    State flying = new State("flying","graphics/enemies/Red-koopa-flying.gif",1,2);
    flying.sprite.align(CENTER, BOTTOM);
    flying.sprite.setAnimationSpeed(0.2);
    flying.sprite.setNoRotation(true);
    flying.sprite.addPathLine(   0,0,1,1,0,
                              -100,0,1,1,0,
                               100);
    flying.sprite.addPathLine(-100,0,1,1,0,
                              -100,0,-1,1,0,
                               5);
    flying.sprite.addPathLine(-100,0,-1,1,0,
                                 0,0,-1,1,0,
                               100);
    flying.sprite.addPathLine(0,0,-1,1,0,
                              0,0,1,1,0,
                              5);
    addState(flying);

    // by default, flying koopas fly
    setCurrentState("flying");
  }

  /**
   * When mario squishes us, we lose our wings.
   */
  boolean squish() {
    if(flying) {
      flying = false;
      setForces(-0.2,DOWN_FORCE);
      setAcceleration(0,ACCELERATION);
      setCurrentState("walking");
      return true;
    }
    return super.squish();
  }
}


// ==========================


/**
 * regular coin
 */
class Coin extends Pickup {
  Coin(float x, float y) {
    super("Regular coin", "graphics/assorted/Regular-coin.gif", 1, 4, x, y);
  }
}

/**
 * dragon coin!
 */
class DragonCoin extends Pickup {
  DragonCoin(float x, float y) {
    super("Dragon coin", "graphics/assorted/Dragon-coin.gif", 1, 10, x, y);
  }
}

/**
 * delicious mushroom
 */
class Mushroom extends Pickup {
  Mushroom(float x, float y) {
    super("Mushroom", "graphics/assorted/Mushroom.gif", 1, 1, x, y);
    getState("Mushroom").sprite.align(CENTER,BOTTOM);
    // make mushroom gently slide to the right
    setImpulseCoefficients(0,0);
    setForces(2, DOWN_FORCE);
    setAcceleration(0,ACCELERATION);
  }
}
