/**
 * Boundaries are unidirectionally passable,
 * and are positionable in the same way that
 * anything else is.
 */
class Boundary extends Positionable {
  private float PI2 = 2*PI;
  
  // things can listen for collisions on this boundary
  ArrayList<BoundaryCollisionListener> listeners;
  
  /**
   * Add a collision listener to this boundary
   */
  void addListener(BoundaryCollisionListener l) { listeners.add(l); }
  
  /**
   * remove a collision listener from this boundary
   */
  void removeListener(BoundaryCollisionListener l) { listeners.remove(l); }
  
  /**
   * notify all listners that a collision occurred.
   */
  void notifyListeners(Actor actor, float[] correction) {
    for(BoundaryCollisionListener l: listeners) {
      l.collisionOccured(this, actor, correction);
    }
  }

  // extended adminstrative values
  float dx, dy, length;
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
    length = sqrt(dx*dx+dy*dy);
    updateBounds();
    updateAngle();
    glide = 1.0;
    listeners = new ArrayList<BoundaryCollisionListener>();
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
  // FIXME: this is not the correct implementation
  boolean supports(Positionable thing) {
    float[] bbox = thing.getBoundingBox(), nbox = new float[8];
    
    // shortcut on "this thing has already been removed"
    if (bbox == null) return false;

    // First, translate all coordinates so that they're
    // relative to the boundary's (x,y) coordinate.
    bbox[0] -= x;   bbox[1] -= y;
    bbox[2] -= x;   bbox[3] -= y;
    bbox[4] -= x;   bbox[5] -= y;
    bbox[6] -= x;   bbox[7] -= y;
   
    // Then, rotate the bounding box so that it's
    // axis-aligned with the boundary line.
    nbox[0] = bbox[0] * cosma - bbox[1] * sinma;
    nbox[1] = bbox[0] * sinma + bbox[1] * cosma;
    nbox[2] = bbox[2] * cosma - bbox[3] * sinma;
    nbox[3] = bbox[2] * sinma + bbox[3] * cosma;
    nbox[4] = bbox[4] * cosma - bbox[5] * sinma;
    nbox[5] = bbox[4] * sinma + bbox[5] * cosma;
    nbox[6] = bbox[6] * cosma - bbox[7] * sinma;
    nbox[7] = bbox[6] * sinma + bbox[7] * cosma;
    
    // Get new bounding box minima/maxima
    float mx = min(min(nbox[0],nbox[2]),min(nbox[4],nbox[6])),
          MX = max(max(nbox[0],nbox[2]),max(nbox[4],nbox[6])),
          my = min(min(nbox[1],nbox[3]),min(nbox[5],nbox[7])),
          MY = max(max(nbox[1],nbox[3]),max(nbox[5],nbox[7]));

    // Now, determine whether we're "off" the boundary...
    boolean outOfBounds = (mx > length) || (MX < 0) || (MY<-1.99);
    
    // if the thing's not out of bounds, it's supported.
    return !outOfBounds;
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
   * redirect a force along this boundary's surface for a specific actor
   */
  float[] redirectForce(Positionable p, float fx, float fy) {
    return redirectForce(fx,fy);
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
    stroke(255);
    line(0, 0, dx, dy);

    // draw an arrow to indicate the pass-through direction
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
