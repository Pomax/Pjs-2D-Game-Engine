/***************************************
 *                                     *
 *   INTERACTORS: RED KOOPA (FLYING)   *
 *                                     *
 ***************************************/


/**
 * A flying red koopa trooper actor
 */
class FlyingKoopa extends Koopa {
  // are we flying or not?
  boolean flying = true;

  /**
   * The constructor for the koopa trooper
   * basically wraps the normal koopa trooper,
   * but gravity does not apply to this one!
   */
  FlyingKoopa(float mx, float my) {
    super(mx, my);
    setForces(0, 0);
    setAcceleration(0, 0);
  }

  /**
   * So, what can flying koopa troopers do?
   */
  void setupStates() {
    super.setupStates();

    // they can fly!
    State flying = new State("flying", "graphics/enemies/Red-koopa-flying.gif", 1, 2);
    flying.sprite.align(CENTER, BOTTOM);
    flying.sprite.setAnimationSpeed(0.2);
    // in fact, they can do a flying patrolling pattern
    flying.sprite.addPathLine(   0, 0, 1, 1, 0, 
    -100, 0, 1, 1, 0, 
    100);
    flying.sprite.addPathLine(-100, 0, 1, 1, 0, 
    -100, 0, -1, 1, 0, 
    5);
    flying.sprite.addPathLine(-100, 0, -1, 1, 0, 
    0, 0, -1, 1, 0, 
    100);
    flying.sprite.addPathLine(0, 0, -1, 1, 0, 
    0, 0, 1, 1, 0, 
    5);
    SoundManager.load(flying, "audio/Squish.mp3");
    addState(flying);

    // by default, flying koopas fly
    setCurrentState("flying");
  }

  /**
   * When mario squishes us, we lose our wings.
   */
  boolean squish() {
    if (flying) {
      flying = false;
      setForces(-0.2, DOWN_FORCE);
      setAcceleration(0, ACCELERATION);
      SoundManager.play(active);
      // trigger some hitpoints
      layer.addDecal(new HitPoints(x, y, 300));
      setCurrentState("walking");
      return true;
    }
    return super.squish();
  }
}
