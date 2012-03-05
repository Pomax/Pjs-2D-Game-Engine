/**
 * Tracking interactors etc. track any
 * Actor(s) in the level, provided they
 * are within tracking distance.
 */
interface Tracker {
  void track(Actor actor, float vx, float vy, float vw, float vh);
}

/**
 * Objects that implement the tracking interface
 * can make use of a GenericTracker object to do
 * the tracking for them, or they can implement
 * their own, more specific, tracking algorithm.
 */
static class GenericTracker {
  /**
   * the generic tracking algorithm simply checks
   * in which direction we must move in order to
   * get closer to the prey. We then try to move
   * in that direction using an impulse.
   */
  static void track(Positionable hunter, Positionable prey, float speed) {
    float x1=prey.x, y1=prey.y, x2=hunter.x, y2=hunter.y;
    float angle = atan2(y2-y1, x2-x1);
    if(angle<0) { angle += 2*PI; }
    float ix = -cos(angle);
    float iy = -sin(angle);
    hunter.addImpulse(speed*ix, speed*iy);
  }
}
