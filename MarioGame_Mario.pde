/***************************************
 *                                     *
 *          ACTORS: MARIO              *
 *                                     *
 ***************************************/


/**
 * Mario, that lovable, portly, moustachioed man.
 */
class Mario extends Player {

  String spriteset = "mario";
  String marioType = "small";

  // every 'step' has an impulse of 1.3
  float speedStep = 1.3;

  // jumping uses an impulse 21 times that of a step
  float speedHeight = 21;

  // The buttons that get to control Mario
  int VK_UP=87, VK_LEFT=65, VK_DOWN=83, VK_RIGHT=68;  // WASD controls
  int BUTTON_A=81, BUTTON_B=69;                       // Q and E for jump/shoot
  
  void mousePressed(int mx, int my, int button) {
    if(button==LEFT) { keyPressed('Q',81); }
    else if(button==RIGHT) { keyPressed('E',69); }
  }
  void mouseReleased(int mx, int my, int button) {
    if(button==LEFT) { keyReleased('Q',81); }
    else if(button==RIGHT) { keyReleased('E',69); }
  }
  
  /**
   * The Mario constructor
   */
  Mario() {
    this("Mario", DAMPENING, DAMPENING);
  }

  Mario(String name, float xdamp, float ydamp) {
    super(name, xdamp, ydamp);
    setForces(0, DOWN_FORCE);
    setAcceleration(0, ACCELERATION);
    // by default, we're small mario
    setupStates("small");
    // and these are the keys we will be allowed to use.
    keyCodes = new int[] {VK_UP, VK_LEFT, VK_DOWN, VK_RIGHT, BUTTON_A, BUTTON_B};
  }

  /**
   * Set up a number of states for Mario to be in.
   */
  void setupStates(String setType) {
    states.clear();
    marioType = setType;

    // when not moving
    State standing = new State("standing", "graphics/mario/"+setType+"/Standing-"+spriteset+".gif");
    standing.sprite.align(CENTER, BOTTOM);
    addState(standing);

    // when either running right or left
    State running = new State("running", "graphics/mario/"+setType+"/Running-"+spriteset+".gif", 1, 4);
    running.sprite.align(CENTER, BOTTOM);
    running.sprite.setAnimationSpeed(0.75);
    addState(running);

    // when [down] is pressed
    State crouching = new State("crouching", "graphics/mario/"+setType+"/Crouching-"+spriteset+".gif");
    crouching.sprite.align(CENTER, BOTTOM);
    addState(crouching);

    // when [up] is pressed
    State looking = new State("looking", "graphics/mario/"+setType+"/Looking-"+spriteset+".gif");
    looking.sprite.align(CENTER, BOTTOM);
    addState(looking);

    // when pressing the A (jump) button
    State jumping = new State("jumping", "graphics/mario/"+setType+"/Jumping-"+spriteset+".gif");
    jumping.sprite.align(CENTER, BOTTOM);
    jumping.sprite.addPathLine(0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 24);
    SoundManager.load(jumping, "audio/Jump.mp3");
    addState(jumping);

    // when pressing the A button while crouching
    State crouchjumping = new State("crouchjumping", "graphics/mario/"+setType+"/Crouching-"+spriteset+".gif");
    crouchjumping.sprite.align(CENTER, BOTTOM);
    crouchjumping.sprite.addPathLine(0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 24);
    SoundManager.load(crouchjumping, "audio/Jump.mp3");
    addState(crouchjumping);

    // when pressing the B (shoot) button
    State spinning = new State("spinning", "graphics/mario/"+setType+"/Spinning-"+spriteset+".gif", 1, 4);
    spinning.sprite.align(CENTER, BOTTOM);
    spinning.sprite.addPathLine(0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 24);
    SoundManager.load(spinning, "audio/Spin jump.mp3");
    addState(spinning);

    // if we mess up, and we're small, we lose...
    if (setType=="small") {
      State dead = new State("dead", "graphics/mario/"+setType+"/Dead-"+spriteset+".gif", 1, 2);
      dead.sprite.align(CENTER, BOTTOM);
      dead.sprite.setAnimationSpeed(0.5);
      dead.sprite.setNoRotation(true);
      dead.sprite.setLooping(false);
      dead.sprite.addPathCurve(0, 0, 1, 1, 0, 
      0, -50, 
      0, 250, 
      0, 1200, 1, 1, 0, 72, 1);
      SoundManager.load(dead, "audio/Dead mario.mp3");
      addState(dead);
    }

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
      if (keyDown[VK_LEFT]) {
        // when we walk left, we need to flip the sprite
        setHorizontalFlip(true);
        // walking left means we get a negative impulse along the x-axis:
        addImpulse(-speedStep, 0);
        setViewDirection(-1, 0);
      }
      if (keyDown[VK_RIGHT]) {
        // when we walk right, we need to NOT flip the sprite =)
        setHorizontalFlip(false);
        // walking right means we get a positive impulse along the x-axis:
        addImpulse( speedStep, 0);
        setViewDirection(1, 0);
      }
    }

    // Because some states will not allow use to change,
    // such as jump animations, we check whether we're
    // allowed to change our state before we check keys.
    if (active.mayChange())
    {
      // The jump button is pressed! Should we jump? How do we jump?
      if (keyDown[BUTTON_A] && boundaries.size()>0) {
        if (active.name != "jumping" && active.name != "crouchjumping" && active.name != "spinning") {
          // first off, jumps may not auto-repeat, so we lock the jump button
          ignore(BUTTON_A);
          // make sure we unglue ourselves from the platform we're standing on:
          detachAll();
          // then generate a massive impulse upward:
          addImpulse(0, speedHeight*-speedStep);
          // now, if we're crouching, we need to crouch-jump.
          // Otherwise, we can jump normally.
          if (active.name == "crouching") { 
            setCurrentState("crouchjumping");
          }
          else { 
            setCurrentState("jumping");
          }
          SoundManager.play(active);
        }
      }

      // The shoot button is pressed! When we don't have a shooty power-up,
      // this makes Mario spin-jump. But should we? And How?
      else if (keyDown[BUTTON_B] && boundaries.size()>0) {
        // first off, shooting and spin jumping may not auto-repeat, so we lock the shoot button
        ignore(BUTTON_B);
        if (marioType=="fire" && active.name != "crouching") {
          shoot();
        }
        else if (marioType!="fire" && active.name != "jumping" && active.name != "crouchjumping" && active.name != "spinning") {
          // make sure we unglue ourselves from the platform we're standing on:
          detachAll();
          // then generate a massive impulse upward:
          addImpulse(0, speedHeight*-speedStep);
          // and then make sure we spinjump, rather than jump normally
          setCurrentState("spinning");
          SoundManager.play(active);
        }
      }
      // The down button is pressed: crouch
      else if (keyDown[VK_DOWN]) {
        if (boundaries.size()==1 && boundaries.get(0) instanceof PipeBoundary) {
          ((PipeBoundary)boundaries.get(0)).teleport();
        }
        setCurrentState("crouching");
      }
      // The up button is pressed: look up
      else if (keyDown[VK_UP]) {
        setCurrentState("looking");
      }
      // The left and/or right buttons are pressed: run!
      else if (keyDown[VK_LEFT] || keyDown[VK_RIGHT]) {
        setCurrentState("running");
      }
      // okay, nothing's being pressed. Let's just stand there.
      else { 
        setCurrentState("standing");
      }
    }
  }

  /**
   * If Mario loses, remove him from the level.
   */
  void handleStateFinished(State which) {
    if (which.name == "dead") {
      // well, we died.. restart!
      level.end();
      level.setSwappable();
    }
  }

  /**
   * When Mario touches down on a platform,
   * which state should he switch to?
   */
  void attachTo(Boundary boundary) {
    super.attachTo(boundary);
    // After crouch-jumping, Mario should be crouching
    if (active.name=="crouchjump") {
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
  void overlapOccurredWith(Actor other, float[] direction) {
    if (other instanceof Koopa) {
      Koopa koopa = (Koopa) other;
      float angle = direction[2];

      // We bopped a koopa on the head!
      float tolerance = radians(75);
      if (PI/2 - tolerance <= angle && angle <= PI/2 + tolerance) {
        boolean shouldJump = koopa.squish();
        if (shouldJump) {
          setImpulse(0, ACCELERATION*speedHeight*-speedStep);
          if (active.name!="spinning") {
            setCurrentState("jumping");
          }
        }
      }

      // Oh no! We missed and touched a koopa!
      else { 
        die();
      }
    }
  }

  /**
   * What happens when we die?
   */
  void die() {
    // wait! are we big? we don't die when we're big!
    if (getState("dead")==null) {
      disableInteractionFor(48);
      setupStates("small");
    }
    // okay, no, we're small. We lose =(
    else {
      setInteracting(false);
      setCurrentState("dead");
      SoundManager.pause(level);
      SoundManager.play(active);
    }
  }

  /**
   * What happens when we get pickups?
   */
  void pickedUp(Pickup pickup) {
    if (pickup.name=="Regular coin") {
      // increase our score
    }
    else if (pickup.name=="Dragon coin") {
      // increase our secret dragon score
    }
    else if (pickup.name=="Mushroom") {
      // become big!
      powerUp();
    }
    else if (pickup.name=="Flower") {
      // obtain fire flower powers!
      flowerPowerUp();
    }
  }

  /**
   * Big mario has different sprites
   */
  void powerUp() {
    setupStates("big");
  }

  /**
   * Fire flower mario has different sprites, too
   */
  void flowerPowerUp() {
    setupStates("fire");
  }

  /**
   * Shoot a fire blob... at the mouse pointer!
   */
  void shoot() {
    // get the unified coordinate values for mario, and the mouse cursor...
    float[] mapped = layer.mapCoordinateToScreen(getX(), getY()-height/2);
    float ax = mapped[0], ay = mapped[1];
    mapped = layer.mapCoordinateFromScreen(mouseX, mouseY);
    float mx = mapped[0], my = mapped[1];
    // because the fire blob gets fired in the direction of the mouse!
    float dx = mx-ax, dy = my-ay,
          len = sqrt(dx*dx + dy*dy),
          speed = 10;
    dx = speed*dx/len;
    dy = speed*dy/len;
    // oh my god, precision aiming fire Mario O_O!
    FireBlob fireblob = new FireBlob(x, y-height/2, dx, dy);
    layer.addForInteractorsOnly(fireblob);
    // also, make a pew pew sound.
    SoundManager.load(fireblob, "audio/Squish.mp3");
    SoundManager.play(fireblob);
  }
}