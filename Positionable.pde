/**
 * Manipulable object: translate, rotate, scale, flip h/v
 */
abstract class Positionable implements Drawable {

  // Positionable objects can be bound to
  // a boundary, which will then be responsible
  // for guiding the impulse vector along its
  // surface, rather than allowing free movement.
  Boundary boundary = null;

  // dimensions and positioning
  float x=0, y=0, width=0, height=0;

  // mirroring
  boolean hflip = false;   // draw horizontall flipped?
  boolean vflip = false;   // draw vertically flipped?

  // transforms
  float ox=0, oy=0;        // offset in world coordinates
  float sx=1, sy=1;        // scale factor
  float r=0;               // rotation (in radians)

  // impulse "vector"
  float ix=0, iy=0;

  // impulse factor per frame (acts as accelator/dampener)
  float ixF=1, iyF=1;

  // external force "vector"
  float fx=0, fy=0;

  // external acceleration "vector"
  float ixA=0, iyA=0;
  int aFrameCount=0;

  // previous x/y coordinate, for trajectory checks
  float prevx=0, prevy=0;

  // administrative
  boolean animated = true;  // does this object move?
  boolean visible = true;   // do we draw this object?

  /**
   * Cheap constructor
   */
  Positionable() {}

  /**
   * Set up a manipulable object
   */
  Positionable(float _x, float _y, float _width, float _height) {
    x = _x; y = _y; width = _width; height = _height;
  }

  /**
   * change the position, absolute
   */
  void setPosition(float _x, float _y) {
    x = _x;
    y = _y;
    prevx = x;
    prevy = y;
    aFrameCount = 0;
  }

  /**
   * change the position, relative
   */
  void moveBy(float _x, float _y) {
    x += _x;
    y += _y;
    prevx = x;
    prevy = y;
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
   * Attach this positionable to a boundary.
   */
  void attachTo(Boundary b) {
    boundary = b;
    b.attach(this);
    aFrameCount = 0;
  }

  /**
   * Detach from whichever boundary we're attached to.
   */
  void detach() {
    if(boundary!=null) {
      boundary.detach(this);
    }
    boundary = null;
    aFrameCount = 0;
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
  float getPrevX() { return prevx + ox; }

  /**
   * get the previous y coordinate.
   */
  float getPrevY() { return prevy + oy; }

  /**
   * get the current x coordinate.
   */
  float getX() { return x + ox; }

  /**
   * get the current y coordinate.
   */
  float getY() { return y + oy; }

  /**
   * get the midpoint
   */
  // FIXME: this doesn't look like a sprite center?
  float getMidX() { return x + ox; }

  /**
   * get the midpoint
   */
  // FIXME: this doesn't look like a sprite center?
  float getMidY() { return y + oy; }

  /**
   * Primitive sprite overlap test: bounding box
   * overlap using midpoint distance.
   */
  float[] overlap(Positionable other) {
    float w=width,h=height,ow=other.width,oh=other.height;
    float xmid1 = getMidX();
    float ymid1 = getMidY();
    float xmid2 = other.getMidX();
    float ymid2 = other.getMidY();
    float dx = xmid2 - xmid1;
    float dy = ymid2 - ymid1;
    float dw = (w + ow)/2;
    float dh = (h + oh)/2;
    // no overlap if the midpoint distance is greater
    // than the dimension half-distances put together.
    if(abs(dx) > dw || abs(dy) > dh) {
      return null;
    }
    // overlap
    float angle = atan2(dy,dx);
    if(angle<0) { angle += 2*PI; }
    return new float[]{dx, dy, angle};
  }

  /**
   * Set up the coordinate transformations
   * and then call whatever implementation
   * of "drawObject" exists.
   */
  void draw(float vx, float vy, float vw, float vh) {
    // Draw, if visible
    if (visible && drawableFor(vx,vy,vw,vh)) {
      pushMatrix();
      {
        translate(x,y);
        if (r != 0) { rotate(r); }
        if(hflip) { scale(-1,1); }
        if(vflip) { scale(1,-1); }
        scale(sx,sy);
        //translate(-width/2 - ox, -height/2 - oy);
        translate(ox, oy);
        drawObject();
      }
      popMatrix();
    }

    // Update position for next the frame,
    // based on impulse and force.
    if(animated) { update(); }
  }
  
  abstract boolean drawableFor(float vx, float vy, float vw, float vh);

  /**
   * Update all the position parameters
   */
  void update() {
    prevx = x;
    prevy = y;
    addImpulse(fx,fy);

    // not on a boundary: unrestricted motion.
    if(boundary==null) {
      x += ix + (aFrameCount * ixA);
      y += iy + (aFrameCount * iyA);
      aFrameCount++;
    }

    // previously on a boundary, but we moved off of it: still
    // restricted motion, which should make sure that we move onto
    // another, joining, platform.
    else if(boundary.outOfBounds(x,y)) {
      Boundary boundary = this.boundary;
      detach();
      // TODO: when we detach, we need to see if we pass
      //       through some other boundary (such as in
      //       corners).
      if(boundary.prev!=null && !boundary.prev.outOfBounds(x,y)) {
        attachTo(boundary.prev);
      }
      else if(boundary.next!=null && !boundary.next.outOfBounds(x,y)) {
        attachTo(boundary.next);
      }
    }

    // we're attached to a boundary, so we're subject to impulse redirection.
    if(boundary!=null) {
      float[] redirected = boundary.redirectForce(x, y, ix + (aFrameCount * ixA), iy + (aFrameCount * iyA));
      x += redirected[0];
      y += redirected[1];
      // if this makes us fly off the boundary, detach
      if(redirected[2]==0) { detach(); }
    }
    // dampen (or boost) our impulse, based on the impulse coefficients
    ix *= ixF;
    iy *= iyF;
  }
  
  /**
   * Back up a position.
   */
  void rewind() {
    // FIXME: this smells very much like a hack
    x = prevx + (x-prevx)*0.5;
    y = prevy + (y-prevy)*0.5;
  }

  // implemented by subclasses
  abstract void drawObject();

  String toString() {
    return x+"/"+y+" im{"+ix+"/"+iy+"} (prev: "+prevx+"/"+prevy+")" ;
  }
}
