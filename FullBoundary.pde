/**
 * Full boundary (objects may no pass from either side)
 */
// FIXME: points get stuck on this boundary =)
class FullBoundary extends Boundary {

  /**
   * pass-through constructor
   */
  FullBoundary(float x1, float y1, float x2, float y2) {
    super(x1,y1,x2,y2);
  }
  
  /**
   * No passing trajectory exists
   */
  boolean safeTrajectory(float x1, float y1, float x2, float y2) {
    return false;
  }
  
  /**
   * no decals for full boundaries
   */
  void drawDecal(float dx, float dy) { }
}
