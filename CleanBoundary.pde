/**
 * Clean boundaries cannot be attached to.
 */
class CleanBoundary extends Boundary {

  // wrapping constructor
  CleanBoundary(float x1, float y1, float x2, float y2) {
    super(x1,y1,x2,y2);
  }

  /**
   * Actors are not allowed to attach.
   * If they try anyway, they'll be told
   * to detach immediately.
   */
  void attach(Positionable a) {
    a.detach(this);
  }
}
