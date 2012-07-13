/**
 * Manipulable object: translate, rotate, scale, flip h/v
 */
abstract class Positionable extends Position implements Drawable {
  // HELPER FUNCTION FOR JAVASCRIPT
  void jsupdate() {
    if(monitoredByJavaScript && javascript != null) {
      javascript.updatedPositionable(this); }}


  /**
   * We track two frames for computational purposes,
   * such as performing boundary collision detection.
   */
  Position previous = new Position();

  /**
   * Boundaries this positionable is attached to.
   */
  ArrayList<Boundary> boundaries;
  
  /**
   * Decals that are drawn along with this positionable,
   * but do not contribute to any overlap or collision
   * detection, nor explicitly interact with things.
   */
  ArrayList<Decal> decals;

  // shortcut variable that tells us whether
  // or not this positionable needs to perform
  // boundary collision checks
  boolean inMotion = false;

  /**
   * Cheap constructor
   */
  Positionable() {
    boundaries = new ArrayList<Boundary>();
    decals = new ArrayList<Decal>();
  }

  /**
   * Set up a manipulable object
   */
  Positionable(float _x, float _y, float _width, float _height) {
    this();
    x = _x;
    y = _y;
    width = _width;
    height = _height;
    ox = width/2;
    oy = -height/2;
  }

  /**
   * change the position, absolute
   */
  void setPosition(float _x, float _y) {
    x = _x;
    y = _y;
    previous.x = x;
    previous.y = y;
    aFrameCount = 0;
    direction = -1;
    jsupdate();
  }

  /**
   * Attach this positionable to a boundary.
   */
  void attachTo(Boundary b) {
    boundaries.add(b);
  }
  
  /**
   * Check whether this positionable is
   * attached to a specific boundary.
   */
  boolean isAttachedTo(Boundary b) {
    return boundaries.contains(b);
  }

  /**
   * Detach this positionable from a
   * specific boundary.
   */
  void detachFrom(Boundary b) {
    boundaries.remove(b);
  }

  /**
   * Detach this positionable from all
   * boundaries that it is attached to.
   */
  void detachFromAll() {
    boundaries.clear();
  }

  /**
   * attach a Decal to this positionable.
   */
  void addDecal(Decal d) {
    decals.add(d);
    d.setOwner(this);
  }

  /**
   * detach a Decal from this positionable.
   */
  void removeDecal(Decal d) {
    decals.remove(d);
  }

  /**
   * detach all Decal from this positionable.
   */
  void removeAllDecals() {
    decals.clear();
  }


  /**
   * change the position, relative
   */
  void moveBy(float _x, float _y) {
    x += _x;
    y += _y;   
    previous.x = x;
    previous.y = y;
    aFrameCount = 0;
    jsupdate();
  }
  
  /**
   * check whether this Positionable is moving. If it's not,
   * it will not be boundary-collision-evalutated.
   */
  void verifyInMotion() {
    inMotion = (ix!=0 || iy!=0 || fx!=0 || fy!=0 || ixA!=0 || iyA !=0);
  }

  /**
   * set the impulse for this object
   */
  void setImpulse(float x, float y) {
    ix = x;
    iy = y;
    jsupdate();
    verifyInMotion();
  }

  /**
   * set the impulse coefficient for this object
   */
  void setImpulseCoefficients(float fx, float fy) {
    ixF = fx;
    iyF = fy;
    jsupdate();
    verifyInMotion();
  }

  /**
   * add to the impulse for this object
   */
  void addImpulse(float _ix, float _iy) {
    ix += _ix;
    iy += _iy;
    jsupdate();
    verifyInMotion();
  }
  
  /**
   * Update which direction this positionable is
   * "looking at".
   */
  void setViewDirection(float dx, float dy) {
    if(dx!=0 || dy!=0) {
      direction = atan2(dy,dx);
      if(direction<0) {
        direction+=2*PI; }}
  }

  /**
   * collisions may force us to stop object's movement.
   */
  void stop() {
    ix = 0;
    iy = 0;
    jsupdate();
  }

  /**
   * Set the external forces acting on this actor
   */
  void setForces(float _fx, float _fy) {
    fx = _fx;
    fy = _fy;
    jsupdate();
    verifyInMotion();
  }

  /**
   * Augment the external forces acting on this actor
   */
  void addForces(float _fx, float _fy) {
    fx += _fx;
    fy += _fy;
    jsupdate();
    verifyInMotion();
  }

  /**
   * set the uniform acceleration for this object
   */
  void setAcceleration(float ax, float ay) {
    ixA = ax;
    iyA = ay;
    aFrameCount = 0;
    jsupdate();
    verifyInMotion();
  }

  /**
   * Augment the accelleration for this object
   */
  void addAccelleration(float ax, float ay) {
    ixA += ax;
    iyA += ay;
    jsupdate();
    verifyInMotion();
  }

  /**
   * set the translation to be the specified x/y values.
   */
  void setTranslation(float x, float y) {
    ox = x;
    oy = y;
    jsupdate();
  }

  /**
   * set the scale to uniformly be the specified value.
   */
  void setScale(float s) {
    sx = s;
    sy = s;
    jsupdate();
  }

  /**
   * set the scale to be the specified x/y values.
   */
  void setScale(float x, float y) {
    sx = x;
    sy = y;
    jsupdate();
  }

  /**
   * set the rotation to be the specified value.
   */
  void setRotation(float _r) {
    r = _r % (2*PI);
    jsupdate();
  }

  /**
   * flip this object horizontally.
   */
  void setHorizontalFlip(boolean _hflip) {
    if(hflip!=_hflip) { ox = -ox; }
    for(Decal d: decals) { d.setHorizontalFlip(_hflip); }
    hflip = _hflip;
    jsupdate();
  }

  /**
   * flip this object vertically.
   */
  void setVerticalFlip(boolean _vflip) {
    if(vflip!=_vflip) { oy = -oy; }
    for(Decal d: decals) { d.setVerticalFlip(_vflip); }
    vflip = _vflip;
    jsupdate();
  }

  /**
   * set this object's visibility
   */
  void setVisibility(boolean _visible) {
    visible = _visible;
    jsupdate();
  }

  /**
   * mark object static or animated
   */
  void setAnimated(boolean _animated) {
    animated = _animated;
    jsupdate();
  }

  /**
   * get the previous x coordinate.
   */
  float getPrevX() { return previous.x + previous.ox; }

  /**
   * get the previous y coordinate.
   */
  float getPrevY() { return previous.y + previous.oy; }

  /**
   * get the current x coordinate.
   */
  float getX() { return x + ox; }

  /**
   * get the current y coordinate.
   */
  float getY() { return y + oy; }

  /**
   * Set up the coordinate transformations
   * and then call whatever implementation
   * of "drawObject" exists.
   */
  void draw(float vx, float vy, float vw, float vh) {
    // Draw, if visible
    if (visible && drawableFor(vx,vy,vw,vh)) {
      pushMatrix();
      applyTransforms();
      drawObject();
      for(Decal d: decals) { d.draw(); }
      popMatrix();
    }

    // Update position for next the frame,
    // based on impulse and force.
    if(animated) { update(); }
  }
  
  /**
   * must be implemented by subclasses,
   * to indicate whether this object is
   * visible in this viewbox.
   */
  abstract boolean drawableFor(float vx, float vy, float vw, float vh);
  
  /**
   * Update all the position parameters.
   * If fixed is not null, it is the boundary
   * we just attached to, and we cannot detach
   * from it on the same frame.
   */
  void update() {
    // cache frame information
    previous.copyFrom(this);

    // work external forces into our current impulse
    addImpulse(fx,fy);

    // work in impulse coefficients (typically, drag)
    ix *= ixF;
    iy *= iyF;

    // not on a boundary: unrestricted motion,
    // so make sure the acceleration factor exists.
    if(boundaries.size()==0) {  aFrameCount++; }

    // we're attached to one or more boundaries, so we
    // are subject to (compound) impulse redirection.
    else {
      aFrameCount = 0;
      float[] redirected = new float[]{ix, iy};
      for(int b=boundaries.size()-1; b>=0; b--) {
        Boundary boundary = boundaries.get(b);
        if(!boundary.disabled) {
          redirected = boundary.redirectForce(this, redirected[0], redirected[1]);
        }
        if(boundary.disabled || !boundary.supports(this)) {
          detachFrom(boundary);
          continue;
        }
      }
      ix = redirected[0];
      iy = redirected[1];
    }

    // Not unimportant: cutoff resolution.
    if(abs(ix) < 0.01) { ix = 0; }
    if(abs(iy) < 0.01) { iy = 0; }

    // update the physical position
    x += ix + (aFrameCount * ixA);
    y += iy + (aFrameCount * iyA);
  }

  /**
   * Reset this positional to its previous state
   */
  void rewind() {
    copyFrom(previous);
    jsupdate();
  }


  // implemented by subclasses
  abstract void drawObject();

  // mostly for debugging purposes 
  String toString() {
    return width+"/"+height + "\n" +
            "current: " + super.toString() + "\n" +
            "previous: " + previous.toString() + "\n";
  }
}
