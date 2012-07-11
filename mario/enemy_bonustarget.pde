class BonusTarget extends MarioEnemy {
  
  ArrayList<HitListener> listeners = new ArrayList<HitListener>();
  void addListener(HitListener l) { if (!listeners.contains(l)) { listeners.add(l); }}
  void removeListener(HitListener l) { listeners.remove(l); }  
  
  float radial = 40;
  
  BonusTarget(float x, float y, float r) {
    super("Bonus Target");
    setPosition(x,y);
    radial = r;
    setupStates();
  }

  void setupStates() {
    State swirl = new State("swirl","graphics/assorted/Target.gif", 1, 4);
    // Set up a circle path using bezier curves.
    // Each curve segment lasts 15 frames.
    float d = radial, k = 0.55 * d;
    swirl.addPathCurve(0,-d,   k,-d,   d,-k,   d,0,  15,1);
    swirl.addPathCurve(d,0,     d,k,    k,d,   0,d,  15,1);
    swirl.addPathCurve(0,d,    -k,d,   -d,k,  -d,0,  15,1);
    swirl.addPathCurve(-d,0,  -d,-k,  -k,-d,  0,-d,  15,1);
    swirl.setLooping(true);
    swirl.setAnimationSpeed(0.5);
    addState(swirl);

    SoundManager.load("target hit", "audio/Squish.mp3");
    SoundManager.load("pipe appears", "audio/Powerup.mp3");
  }

  void setPathOffset(int offset) {
    getState("swirl").sprite.setPathOffset(offset);
  }

  // when a target is hit, we want to tell our bonus level about that.
  void pickedUp(Pickup pickup) {
    SoundManager.play("target hit");
    for(HitListener l: listeners) {
      l.targetHit();
    }
  }

  /**
   * What happens when we touch another actor?
   */
  void overlapOccurredWith(Actor other, float[] direction) {
    if (other instanceof Mario) {
      Mario m = (Mario) other;
      m.hit();
    }
  }
}

/**
 * necessary for counting targets shot down
 */
interface HitListener { void targetHit(); }
