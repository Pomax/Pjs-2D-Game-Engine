/**
 * Boundaries are unidirectionally passable,
 * and are positionable in the same way that
 * anything else is.
 */
class Boundary extends Positionable {
  private float PI2 = 2*PI;

  // extended adminstrative values
  float dx, dy;
  float xw, yh;
  float minx, maxx, miny, maxy;
  float angle, cosa, sina, cosma, sinma;
  // <1 means friction, =1 means frictionless, >1 means speed boost!
  float glide;

  // boundaries can be linked
  Boundary prev, next;
  
  float boundingThreshold = 1.5;
  
  boolean disabled = false;

  /**
   * When we build a boundary, we record a
   * vast number of shortcut values so we
   * don't need to recompute them constantly.
   */
  Boundary(float x1, float y1, float x2, float y2) {
    // coordinates
    x = x1;
    y = y1;
    xw = x2;
    yh = y2; 
    // deltas
    dx = x2-x1;
    dy = y2-y1;
    updateBounds();
    updateAngle();
    glide = 1.0;
  }
  
  /**
   * Update our bounding box information
   */
  void updateBounds() {
    xw = x + dx;
    yh = y + dy;
    minx = min(x, xw);
    maxx = max(x, xw);
    miny = min(y, yh);
    maxy = max(y, yh);
  }
  
  /**
   * Update our angle in the world
   */
  void updateAngle() {
    angle = atan2(dy, dx);
    if (angle < 0) angle += 2*PI;
    cosma = cos(-angle);
    sinma = sin(-angle);
    cosa = cos(angle);
    sina = sin(angle);
  }

  void setPosition(float _x, float _y) {
    super.setPosition(_x,_y);
    updateBounds();
  }
  
  void moveBy(float dx, float dy) {
    super.moveBy(dx,dy);
    updateBounds();
  }

  /**
   * This boundary is part of a chain, and
   * the previous boundary is:
   */
  void setPrevious(Boundary b) { prev = b; }

  /**
   * This boundary is part of a chain, and
   * the next boundary is:
   */
  void setNext(Boundary b) { next = b; }

  /**
   * Enable this boundary
   */
  void enable() { disabled = false; }

  /**
   * Disable this boundary
   */
  void disable() { disabled = true; }

  /**
   * Is this positionable actually
   * supported by this boundary?
   */
  boolean supports(Positionable thing) {
    // are all corner dot products above "just above 0"?
    float dotx = xw-x,
          doty = yh-y,
          otlen = sqrt(dotx*dotx + doty*doty),
          tx, ty, dx, dy, len, dotproduct=-2;

    float[] current = thing.getBoundingBox();

    // normalised boundary vector
    dotx /= otlen;
    doty /= otlen;

    // note: we want the dot product with the
    // vector that is perpendicular to the boundary!
    float p = PI/2, cosp = cos(p), sinp = sin(p),
          pdx = dotx*cosp - doty*sinp,
          pdy = dotx*sinp + doty*cosp;

    // how many corners are blocked in [current]?
    float proximity = -2;
    for(int i=0; i<8; i+=2) {
      tx = current[i];
      ty = current[i+1];
      dx = tx-x;
      dy = ty-y;
      len = sqrt(dx*dx+dy*dy);
      dx /= len;
      dy /= len;
      dotproduct = dx*pdx + dy*pdy;
      if (dotproduct > proximity) {
        proximity = dotproduct;
      }
    }
//    println("dot-proximity to boundary: "+proximity);
    return abs(proximity) < 0.01;
  }

  /**
   * If our direction of travel goes through the boundary in
   * the "allowed" direction, don't bother collision detection.
   */
  boolean allowPassThrough(float ix, float iy) {
    float[] aligned = CollisionDetection.translateRotate(0,0,ix,iy, 0,0,dx,dy, angle,cosma,sinma);
    return (aligned[3] < 0);
  }

  /**
   * redirect a force along this boundary's surface.
   */
  float[] redirectForce(float fx, float fy) {
    float[] redirected = {fx,fy};
    if(allowPassThrough(fx,fy)) { return redirected; }
    float[] tr = CollisionDetection.translateRotate(0,0,fx,fy, 0,0,dx,dy, angle,cosma,sinma);
    redirected[0] = glide * tr[2] * cosa;
    redirected[1] = glide * tr[2] * sina;
    return redirected;
  }

  /**
   * Can this object be drawn in this viewbox?
   */
  boolean drawableFor(float vx, float vy, float vw, float vh) {
    // boundaries are invisible to begin with.
    return true;
  }

  /**
   * draw this platform
   */
  void drawObject() {
    strokeWeight(1);
    stroke(255, 0, 255);
    line(0, 0, dx, dy);

    // draw an arrow to indicate the pass-through direction
    stroke(127);
    float cs = cos(angle-PI/2), ss = sin(angle-PI/2);

    float fx = 10*cs;
    float fy = 10*ss;
    line((dx-fx)/2, (dy-fy)/2, dx/2 + fx, dy/2 + fy);

    float fx2 = 6*cs - 4*ss;
    float fy2 = 6*ss + 4*cs;
    line(dx/2+fx2, dy/2+fy2, dx/2 + fx, dy/2 + fy);

    fx2 = 6*cs + 4*ss;
    fy2 = 6*ss - 4*cs;
    line(dx/2+fx2, dy/2+fy2, dx/2 + fx, dy/2 + fy);
  }

  /**
   * Useful for debugging
   */
  String toString() { return x+","+y+","+xw+","+yh; }
}

