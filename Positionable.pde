/**
 * Manipulable object: translate, rotate, scale, flip h/v
 */
abstract class Positionable {

// === TEMPORARY TESTING FUNCTIONS ===

  // are we attached to a boundary?
  Boundary boundary = null;
  void attachTo(Boundary b) { boundary = b; b.attach(this); }
  void detach() { if(boundary!=null) boundary.detach(this); boundary = null; }

// === TEMPORARY TESTING FUNCTIONS ===


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
   * change the position
   */
  void setPosition(float _x, float _y) {
    x = _x;
    y = _y;
    prevx = x;
    prevy = y;
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
   * Set up the coordinate transformations
   * and then call whatever implementation
   * of "drawObject" exists.
   */
  void draw() {
    // Draw, if visible
    if (visible) {
      pushMatrix();
      {
        translate(x, y);
        if (r != 0) { rotate(r); }
        if(hflip) { scale(-1,1); }
        if(vflip) { scale(1,-1); }
        scale(sx,sy);
        translate(-width/2 - ox, -height/2 - oy);
        drawObject();
      }
      popMatrix();
    }

    // Update position for next the frame,
    // based on impulse and force.
    if(animated) {
      prevx = x;
      prevy = y;
      addImpulse(fx,fy);

      // not on a boundary: unrestricted motion.
      if(boundary==null) {
        x += ix;
        y += iy;
      }

      // previously on a boundary, but we moved off of it: unrestricted motion,
      // and make sure to notify the boundary that we are no longer attached.
      else if(boundary.outOfBounds(x,y)) {
        x += ix;
        y += iy;
        detach();
        // TODO: when we detach, we need to see if we pass
        //       through some other boundary (such as in
        //       corners).
      }

      // we're attached to a boundary, so we're subject to impulse redirection.
      else {
        float[] redirected = boundary.redirectForce(x, y, ix, iy);
        x += redirected[0];
        y += redirected[1];
        // if this makes us fly off the boundary, detach
        if(redirected[2]==0) { detach(); }
      }
      // dampen (or boost) our impulse, based on the impulse coefficients
      ix *= ixF;
      iy *= iyF;
    }
  }

  // implemented by subclasses
  abstract void drawObject();
  
  String toString() {
    return x+"/"+y+" im{"+ix+"/"+iy+"} (prev: "+prevx+"/"+prevy+")" ;
  }
}
