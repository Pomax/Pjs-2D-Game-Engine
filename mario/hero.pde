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
   * When we touch down on a boundary,
   * and we're in our jump animation,
   * just go back to the idle state.
   */
  void gotBlocked(Boundary b, float[] intersection) {
//    if(active.name=="jumping") {
//      setCurrentState("idle");
//    }
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
