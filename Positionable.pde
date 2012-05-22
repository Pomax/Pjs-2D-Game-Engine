/**
 * Manipulable object: translate, rotate, scale, flip h/v
 */
abstract class Positionable extends Position implements Drawable {

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
   * Cheap constructor
   */
  Positionable() {
    Computer.positionables();
    boundaries = new ArrayList<Boundary>();
    Computer.arraylists("Boundary");
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
  }

  void attachTo(Boundary b) {
    boundaries.add(b);
  }
  
  boolean isAttachedTo(Boundary b) {
    println("attached to b? " + boundaries.size() + " attachments found.");
    return boundaries.contains(b);
  }

  void detachFrom(Boundary b) {
    boundaries.remove(b);
  }

  void detachFromAll() {
    boundaries.clear();
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
  }

  /**
   * set the impulse for this object
   */
  void setImpulse(float x, float y) {
    ix = x;
    iy = y;
  }

  /**
   * set the impulse coefficient for this object
   */
  void setImpulseCoefficients(float fx, float fy) {
    ixF = fx;
    iyF = fy;
  }

  /**
   * add to the impulse for this object
   */
  void addImpulse(float _ix, float _iy) {
    ix += _ix;
    iy += _iy;
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
  }

  /**
   * Set the external forces acting on this actor
   */
  void setForces(float _fx, float _fy) {
    fx = _fx;
    fy = _fy;
  }

  /**
   * Augment the external forces acting on this actor
   */
  void addForces(float _fx, float _fy) {
    fx += _fx;
    fy += _fy;
  }

  /**
   * set the uniform acceleration for this object
   */
  void setAcceleration(float ax, float ay) {
    ixA = ax;
    iyA = ay;
    aFrameCount = 0;
  }

  /**
   * Augment the accelleration for this object
   */
  void addAccelleration(float ax, float ay) {
    ixA += ax;
    iyA += ay;
  }

  /**
   * set the translation to be the specified x/y values.
   */
  void setTranslation(float x, float y) {
    ox = x;
    oy = y;
  }

  /**
   * set the scale to uniformly be the specified value.
   */
  void setScale(float s) {
    sx = s;
    sy = s;
  }

  /**
   * set the scale to be the specified x/y values.
   */
  void setScale(float x, float y) {
    sx = x;
    sy = y;
  }

  /**
   * set the rotation to be the specified value.
   */
  void setRotation(float _r) {
    r = _r % (2*PI);
  }

  /**
   * flip this object horizontally.
   */
  void setHorizontalFlip(boolean _hflip) {
    if(hflip!=_hflip) { ox = -ox; }
    hflip = _hflip;
  }

  /**
   * flip this object vertically.
   */
  void setVerticalFlip(boolean _vflip) {
    if(vflip!=_vflip) { oy = -oy; }
    vflip = _vflip;
  }

  /**
   * set this object's visibility
   */
  void setVisibility(boolean _visible) {
    visible = _visible;
  }

  /**
   * mark object static or animated
   */
  void setAnimated(boolean _animated) {
    animated = _animated;
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
   * Update all the position parameters
   */
  void update() {
    // cache frame information
    previous.copyFrom(this);

    // work external forces into our current impulse
    addImpulse(fx,fy);

    float _dx = ix + (aFrameCount * ixA),
          _dy = iy + (aFrameCount * iyA);

    // not on a boundary: unrestricted motion.
    if(boundaries.size()==0) {
      aFrameCount++;
      x += _dx;
      y += _dy;
    }

    // we're attached to one or more boundaries, so we
    // are subject to (compound) impulse redirection.
    if(boundaries.size()>0) {
      println("redirecting impulse {"+_dx+","+_dy+"} over boundary surfaces...");
      float[] redirected = new float[]{_dx, _dy};
      for(int b=boundaries.size()-1; b>=0; b--) {
        Boundary boundary = boundaries.get(b);
        if(!boundary.supports(this)) {
          detachFrom(boundary);
          continue;
        }
        redirected = boundary.redirectForce(redirected[0], redirected[1]);
        println("redirected to {"+redirected[0]+","+redirected[1]+"}.");
      }
      x += redirected[0];
      y += redirected[1];
    }

    ix *= ixF;
    iy *= iyF;

    // Not unimportant: round the impulse to two significant decimals,
    // or these values don't stabilise for about 100 frames even though
    // on-screem it looks like we're standing still.
    ix = round(100*ix)/100;
    iy = round(100*iy)/100;
  }

  // implemented by subclasses
  abstract void drawObject();

  // mostly for debugging purposes 
  String toString() {
    return "current: " + toString() + "\n" +
            "previous: " + previous.toString() + "\n";
  }
}
