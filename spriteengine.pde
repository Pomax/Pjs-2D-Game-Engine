// ====== LET'S GET OUR NINTENDO ON! ======

Level level;

// boilerplate
void setup() {
  size(512,432);
  frameRate(24);
  // It is essential that this is called
  // before any sprites are made:
  SpriteMapHandler.setSketch(this);
  level = new TestLevel(); }

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
  Actor mario;

  /**
   * Test level implementation
   */
  TestLevel()
  {
    // background sprite
    Sprite bgsprite = new Sprite("graphics/backgrounds/sky.png", 1, 1);
    bgsprite.align(RIGHT, TOP);
    TilingSprite backdrop = new TilingSprite(bgsprite, 0, 0, width, height);
    npss.add(backdrop);

    // screen boundaries
    float pad = 10;

    // "ground" parts of the level
    Sprite groundsprite = new Sprite("graphics/backgrounds/ground-top.png", 1, 1);
    TilingSprite groundline = new TilingSprite(groundsprite, 0, height-40, 2*width, height - 40 + groundsprite.height);
    npss.add(groundline);
    Sprite groundfillsprite = new Sprite("graphics/backgrounds/ground-filler.png", 1, 1);
    TilingSprite groundfiller = new TilingSprite(groundfillsprite, 0, height-40 + groundsprite.height, 2*width, height);
    npss.add(groundfiller);
    boundaries.add(new Boundary(-pad,height-48,width+pad,height-48));
    Sprite groundslant = new Sprite("graphics/backgrounds/ground-slant.png",1,1);
    groundslant.align(RIGHT,TOP);
    groundslant.setPosition(width/2, height - groundslant.height - 48);
    boundaries.add(new Boundary(width/2, height - groundslant.height, width/2 + 48, height - groundslant.height - 48));
    npss.add(groundslant);

    // clouds platforms!
    boundaries.add(new Boundary(54 +   0, 96 +   0, 105 +   0, 96 +   0));
    boundaries.add(new Boundary(54 + 224, 96 +  48, 105 + 224, 96 +  48));
    boundaries.add(new Boundary(54 + 336, 96 +  32, 105 + 336, 96 +  32));
    boundaries.add(new Boundary(54 + 256, 96 + 192, 105 + 256, 96 + 192));
    boundaries.add(new Boundary(54 + 336, 96 + 208, 105 + 336, 96 + 208));
    boundaries.add(new Boundary(54 + 138, 96 + 144, 105 + 112, 96 + 144));
    boundaries.add(new Boundary(54 + 186, 96 + 160, 105 + 160, 96 + 160));
    boundaries.add(new Boundary(54 + 330, 96 + 256, 105 + 322, 96 + 256));

    // let's a-make a di Mario:
    mario = new Mario();
    mario.setPosition(width/2,height/2);
    mario.setForces(0,1);
    actors.add(mario);
  }

  /**
   * Render mario in glorious canvas definition
   */
  void draw() {
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
    Actor koopa = new Koopa(mx, my);
    koopa.setPosition(mx, my);
    koopa.setForces(-0.2,1);
    npas.add(koopa);
  }
}


// ========== TEST ACTOR: MARIO ============


/**
 * Mario, that lovable, portly, moustachioed man.
 */
class Mario extends Actor {

  // every 'step' has an impulse of 1.3
  float speedStep = 1.3;

  // jumping uses an impulse 19 times that of a step
  float speedHeight = 19;

  /**
   * The Mario constructor
   */
  Mario() {
    // Set up impulse dampening at 80% per frame,
    // for that old school "slidy" feel.
    super(0.8, 0.8);
    // Just an actor can't "do" anything; we need
    // to define some states for this actor.
    setupStates();
  }

  /**
   * Set up a number of states for Mario to be in.
   */
  void setupStates() {
    // Load mario from his "small" sprite set, for now.
    String sizeSet = "small";
    
    // when not moving
    State standing = new State("standing","graphics/mario/"+sizeSet+"/Standing-mario.png",1,1);
    standing.sprite.align(CENTER, BOTTOM);
    addState(standing);

    // when either running right or left
    State running = new State("running","graphics/mario/"+sizeSet+"/Running-mario.png",1,4);
    running.sprite.align(CENTER, BOTTOM);
    running.sprite.setAnimationSpeed(0.75);
    addState(running);

    // when [down] is pressed
    State crouching = new State("crouching","graphics/mario/"+sizeSet+"/Crouching-mario.png",1,1);
    crouching.sprite.align(CENTER, BOTTOM);
    addState(crouching);
  
    // when [up] is pressed
    State looking = new State("looking","graphics/mario/"+sizeSet+"/Looking-mario.png",1,1);
    looking.sprite.align(CENTER, BOTTOM);
    addState(looking);

    // when pressing the A (jump) button
    State jumping = new State("jumping","graphics/mario/"+sizeSet+"/Jumping-mario.png",1,1);
    jumping.sprite.align(CENTER, BOTTOM);
    jumping.sprite.addPathLine(0,0,1,1,0,  0,0,1,1,0,  24);
    addState(jumping);

    // when pressing the A button while crouching
    State crouchjumping = new State("crouchjumping","graphics/mario/"+sizeSet+"/Crouching-mario.png",1,1);
    crouchjumping.sprite.align(CENTER, BOTTOM);
    crouchjumping.sprite.addPathLine(0,0,1,1,0,  0,0,1,1,0,  24);
    addState(crouchjumping);

    // when pressing the B (shoot) button
    State spinning = new State("spinning","graphics/mario/"+sizeSet+"/Spinning-mario.png",1,4);
    spinning.sprite.align(CENTER, BOTTOM);
    spinning.sprite.addPathLine(0,0,1,1,0,  0,0,1,1,0,  24);
    addState(spinning);
    
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
          lock(BUTTON_A);
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
          lock(BUTTON_B);
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

  // required method
  void handleStateFinished(State which) {}
  
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
}


// ========== TEST ACTOR: KOOPA ============


/**
 * A red koopa trooper actor
 */
class Koopa extends Actor {

  /**
   * The constructor for the koopa trooper
   * is essentially the same as for Mario.
   */
  Koopa(int mx, int my) {
    // koopas are slowed down at the same pace that Mario is.
    super(0.8, 0.8);
    // Just like Mario, a koopa trooper can't "do" anything.
    // We need to define some states for this actor.
    setupStates();
  }

  /**
   * So, what can koopa troopers do?
   */
  void setupStates() {
    // koopa has one state at the moment.
    State walking = new State("walking","graphics/enemies/Red-koopa-walking.png",1,2);
    walking.sprite.align(CENTER, BOTTOM);
    walking.sprite.setAnimationSpeed(0.25); 
    addState(walking);
  }

  void handleInput() {
    // While we don't let players control
    // koopa troopers... we could!
  }

  void handleStateFinished(State which) {
    // Because koopa troopers only have one
    // state, there's nothing else to switch to.
  }
}
