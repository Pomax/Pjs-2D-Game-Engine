/**
 * Our dapper hero
 */
class Mario extends Player {

  int score = 0;
  float speed = 2.5;
  boolean canShoot = false;
  String spriteSet = "mario";
  String type = "small";
  
  /**
   * Mario can carry keys! It's magical!
   */
  Decal key = null;
  boolean hasKey = false; 
  void getKey() { hasKey = true; key = new KeyDecal(width,0); addDecal(key); }
  void removeKey() { hasKey = false; removeDecal(key); }

  Mario() {
    super("Mario");
    setupStates(spriteSet, type);
    setCurrentState("idle");
    // input handling
    handleKey('W');
    handleKey('A');
    handleKey('S');
    handleKey('D');
    // forces that act on Mario
    setImpulseCoefficients(DAMPENING, DAMPENING);
    setForces(0, DOWN_FORCE);
    setAcceleration(0, ACCELERATION);
  }

  void setSpriteSet(String setName) {
    spriteSet = setName;
    setupStates(spriteSet,type);
  }

  void setSpriteType(String typeName) {
    type = typeName;
    setupStates(spriteSet,type);
  }
  
  // make sure all states are center/bottom anchored
  void addState(State st) {
    st.sprite.anchor(CENTER, BOTTOM);
    super.addState(st);
  }

  /**
   * Set up our states
   */
  void setupStates(String spriteSet, String type) {
    // idling state
    addState(new State("idle", "graphics/"+spriteSet+"/"+type+"/Standing-mario.gif"));

    // crouching state
    addState(new State("crouching", "graphics/"+spriteSet+"/"+type+"/Crouching-mario.gif"));

    // running state
    addState(new State("running", "graphics/"+spriteSet+"/"+type+"/Running-mario.gif", 1, 4));

    // dead state O_O
    if(type == "small") {
      State dead = new State("dead", "graphics/"+spriteSet+"/"+type+"/Dead-mario.gif", 1, 2);
      dead.setAnimationSpeed(0.25);
      dead.setDuration(100);
      addState(dead);   
      SoundManager.load(dead, "audio/Dead mario.mp3");
    }

    // jumping state
    State jumping = new State("jumping", "graphics/"+spriteSet+"/"+type+"/Jumping-mario.gif");
    jumping.setDuration(15);
    addState(jumping);
    SoundManager.load(jumping, "audio/Jump.mp3");

    // crouchjumping state
    State crouchjumping = new State("crouchjumping", "graphics/"+spriteSet+"/"+type+"/Crouching-mario.gif");
    crouchjumping.setDuration(15);
    addState(crouchjumping);
    SoundManager.load(crouchjumping, "audio/Jump.mp3");

    // victorious state!
    State won = new State("won", "graphics/"+spriteSet+"/"+type+"/Standing-mario.gif");
    won.setDuration(240);
    addState(won);
    
    // being hit requires a sound effect too
    SoundManager.load("mario hit", "audio/Pipe.mp3");
  }

  /**
   * Handle input
   */
  void handleInput() {
    if (spriteSet == "mario") {
      handleMarioInput();
    }
  }

  void handleMarioInput() {
    // we don't handle any input when we're dead~
    if (active.name=="dead" || active.name=="won") return;

    // what do we "do"? (i.e. movement wise)
    if (active.name!="crouching" && (isKeyDown('A') || isKeyDown('D'))) {
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

    // if the jump key is pressed, and we're standing on something, let's jump! 
    if (active.mayChange() && isKeyDown('W') && boundaries.size()>0) {
      ignore('W');
      // generate a massive impulse upward
      addImpulse(0, -35);
      // and make sure we look like we're jumping, too
      if (active.name!="crouching") {
        setCurrentState("jumping");
      } else {
        setCurrentState("crouchjumping");
      }
      SoundManager.play(active);
    }

    // if we're not jumping, but left or right is pressed,
    // make sure we're using the "running" state.
    if (isKeyDown('S')) {
      if (boundaries.size()>0) {
        for(Boundary b: boundaries) {
          if(b instanceof PipeBoundary) {
            ((PipeBoundary)b).trigger(this);
          }
        }
      }
      if (active.name=="jumping") {
        setCurrentState("crouchjumping");
      } else {
        setCurrentState("crouching");
      }
    }

    // and what do we look like when we do this?
    if (active.mayChange())
    {
      if (active.name!="crouching" && (isKeyDown('A') || isKeyDown('D'))) {
       setCurrentState("running");
      }

      // if we're not actually doing anything,
      // then we change the state to "idle"
      else if (noKeysDown()) {
        setCurrentState("idle");
      }
    }
  }

  /**
   * When 'fixed frame count' animations end
   * such as the jump animation, what should we do?
   */
  void handleStateFinished(State which) {
    if (which.name == "dead" || which.name == "won") {
      removeActor();
      reset();
    } 
    else { setCurrentState("idle"); }
  }

  /**
   * What happens when we touch another actor?
   */
  void overlapOccurredWith(Actor other, float[] direction) {
    if (other instanceof MarioEnemy) {
      MarioEnemy enemy = (MarioEnemy) other;
      float angle = direction[2];

      // We bopped a koopa on the head!
      float tolerance = radians(75);
      if (PI/2 - tolerance <= angle && angle <= PI/2 + tolerance) {
        enemy.hit();
        stop(0, 0);
        setImpulse(0, -30);
        if (spriteSet == "mario") {
          setCurrentState("jumping");
        }
      }

      // Oh no! We missed and touched a koopa!
      else { hit(); }
    }
  }
  
  void hit() {
    if(isDisabled()) return; 
    if(type != "small") {
      setSpriteType("small");
      disableInteractionFor(30);
      SoundManager.play("mario hit");
      return;
    }
    // else:
    die();
  }

  /**
   * When we die, we need to go in the funky "oh no we lost~" dance dive.
   */
  void die() {
    setCurrentState("dead");
    setInteracting(false);
    setImpulse(0, -30);
    setForces(0, 3);
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
      if (spriteSet == "rtype") {
        setForces(0, DOWN_FORCE);
        setAcceleration(0, ACCELERATION);
      }
      spriteSet = "mario";
      Level level = layer.getLevel();
      setCurrentState("won");
      layer.parent.finish();
    }
    // big mario
    else if (pickup.name=="Mushroom") {
      setSpriteType("big");
      disableInteractionFor(30);
    }
    // fire mario
    else if (pickup.name=="Fire flower") {
      // we could effect a full sprite swap here
      canShoot = true;
      setSpriteType("fire");
    }
    // key?
    else if (pickup.name=="Key") {
      getKey();
    }
  }
  
  void mousePressed(int mx, int my, int mb) {
    if (canShoot) {
      if (spriteSet == "rtype") {
        shoot(20, 0);
      } 
      else {
        float[] mi = layer.getMouseInformation(getX(), getY(), mx, my);
        float speed = 10, 
        dx = mi[0], 
        dy = mi[1], 
        len = sqrt(dx*dx + dy*dy);
        dx/=len;
        dy/=len;
        shoot(speed*dx, speed*dy);
      }
    }
  }

  void shoot(float dx, float dy) {
    FireBlob fb = new FireBlob(getX(), getY());
    fb.addImpulse(dx, dy);
    layer.addForInteractorsOnly(fb);
  }
}

