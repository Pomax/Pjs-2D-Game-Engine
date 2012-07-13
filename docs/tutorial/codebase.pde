/**
 * Actors represent something or someone,
 * and can consist of one or more states,
 * each associated with a particular sprite,
 * and each associated with particular
 * behaviour.
 *
 * The Actor class is abstract: you must
 * implement your own subclass before you
 * can make use of it.
 */
abstract class Actor extends Positionable {
  boolean debug = true;
  
  // debug bounding box alignment
  float halign=0, valign=0;

  // are we colliding with another actor?
  boolean colliding = false;

  // regular interaction with other actors
  boolean interacting = true;
  
  // only interact with players
  boolean onlyplayerinteraction = false;
  
  // bypass regular interaction for ... frames
  int disabledCounter = 0;

  // should we be removed?
  boolean remove = false;
  
  // is this actor persistent with respect to viewbox draws?
  boolean persistent = true;
  boolean isPersistent() { return persistent; }

  // the layer this actor is in
  LevelLayer layer;

  // The active state for this actor (with associated sprite)
  State active;

  // all states for this actor
  HashMap<String, State> states;

  // actor name
  String name = "";
  
  // simple constructor
  Actor(String _name) {
    name = _name;
    states = new HashMap<String, State>();
  }

  // full constructor
  Actor(String _name, float dampening_x, float dampening_y) {
    this(_name);
    setImpulseCoefficients(dampening_x, dampening_y);
  }

  /**
   * Add a state to this actor's repetoire.
   */
  void addState(State state) {
    state.setActor(this);
    boolean replaced = (states.get(state.name) != null);
    states.put(state.name, state);
    if(!replaced || (replaced && state.name == active.name)) {
      if (active == null) { active = state; }
      else { swapStates(state); }
      updatePositioningInformation();
    }
  }
  
  /**
   * Get a state by name.
   */
  State getState(String name) {
    return states.get(name);
  }
  
  /**
   * Get the current sprite image
   */
  PImage getSpriteMask() {
    if(active == null) return null;
    return active.sprite.getFrame();
  }
  
  /**
   * Tell this actor which layer it is operating in
   */
  void setLevelLayer(LevelLayer layer) {
    this.layer = layer;
  }

  /**
   * Tell this actor which layer it is operating in
   */
  LevelLayer getLevelLayer() {
    return layer;
  }

  /**
   * Set the actor's current state by name.
   */
  void setCurrentState(String name) {
    State tmp = states.get(name);
    if (active != null && tmp != active) {
      tmp.reset();
      swapStates(tmp);
    } else { active = tmp; }
  }
  
  /**
   * Swap the current state for a different one.
   */
  void swapStates(State tmp) {
    // get pertinent information
    Sprite osprite = active.sprite;
    boolean hflip = false, vflip = false;
    if (osprite != null) {
      hflip = osprite.hflip;
      vflip = osprite.vflip;
    }

    // upate state to new state
    active = tmp;
    Sprite nsprite = tmp.sprite;
    if (nsprite != null) {
      if (hflip) nsprite.flipHorizontal();
      if (vflip) nsprite.flipVertical();
      updatePositioningInformation();

      // if both old and new states had sprites,
      // make sure the anchors line up.
      if (osprite != null) {
        handleSpriteSwap(osprite, nsprite);
      }
    }
  }

  /**
   * Move actor if this state changes
   * makes the actor bigger than before,
   * and we're attached to boundaries.
   */
  void handleSpriteSwap(Sprite osprite, Sprite nsprite) {
    float ax1 = osprite.hanchor,
          ay1 = osprite.vanchor,
          ax2 = nsprite.hanchor,
          ay2 = nsprite.vanchor;
    float dx = (ax2-ax1)/2.0, dy = (ay2-ay1)/2.0;
    x -= dx;
    y -= dy;
  }

  /**
   * update the actor dimensions based
   * on the currently active state.
   */
  void updatePositioningInformation() {
    width  = active.sprite.width;
    height = active.sprite.height;
    halign = active.sprite.halign;
    valign = active.sprite.valign;
  }

  /**
   * constrain the actor position based on
   * the layer they are located in.
   */
  void constrainPosition() {
    float w2 = width/2, lw = layer.width;
    if (x < w2) { x = w2; }
    if (x > lw - w2) { x = lw - w2; }
  }

  /**
   * Get the bounding box for this actor
   */
  float[] getBoundingBox() {
    if(active==null) return null;
    
    float[] bounds = active.sprite.getBoundingBox();
    
    // transform the bounds, based on local translation/scale/rotation
    if(r!=0) {
      float x1=bounds[0], y1=bounds[1],
            x2=bounds[2], y2=bounds[3],
            x3=bounds[4], y3=bounds[5],
            x4=bounds[6], y4=bounds[7];
      // rotate
      bounds[0] = x1*cos(r) - y1*sin(r);
      bounds[1] = x1*sin(r) + y1*cos(r);
      bounds[2] = x2*cos(r) - y2*sin(r);
      bounds[3] = x2*sin(r) + y2*cos(r);
      bounds[4] = x3*cos(r) - y3*sin(r);
      bounds[5] = x3*sin(r) + y3*cos(r);
      bounds[6] = x4*cos(r) - y4*sin(r);
      bounds[7] = x4*sin(r) + y4*cos(r);
    }
    // translate
    bounds[0] += x+ox; bounds[1] += y+oy;  // top left
    bounds[2] += x+ox; bounds[3] += y+oy;  // top right
    bounds[4] += x+ox; bounds[5] += y+oy;  // bottom right
    bounds[6] += x+ox; bounds[7] += y+oy;  // bottom left

    // done
    return bounds;
  }

  /**
   * check overlap between sprites,
   * rather than between actors.
   */
  float[] overlap(Actor other) {
    float[] overlap = super.overlap(other);
    if(overlap==null || active==null || other.active==null) {
      return overlap;
    }
    //
    // TODO: add in code here that determines
    //       the intersection point for the two
    //       sprites, and checks the mask to see
    //       whether both have non-zero alph there.
    //
    return overlap;
  }

  /**
   * What happens when we touch another actor?
   */
  void overlapOccurredWith(Actor other, float[] direction) {
    colliding = true;
  }
  
  /**
   * What happens when we get hit
   */
  void hit() { /* can be overwritten */ }

  /**
   * attach an actor to a boundary, so that
   * impulse is redirected along boundary
   * surfaces.
   */  
  void attachTo(Boundary boundary, float[] correction) {
    // don't add boundaries we're already attached to
    if(boundaries.contains(boundary)) return;
    
    // record attachment
    boundaries.add(boundary);

    // stop the actor
    float[] original = {this.ix - (fx*ixF), this.iy - (fy*iyF)};
    stop(correction[0], correction[1]);

    // then impart a new impulse, as redirected by the boundary.
    float[] rdf = boundary.redirectForce(original[0], original[1]);
    addImpulse(rdf[0], rdf[1]);

    // call the blocked handler
    gotBlocked(boundary, correction, original);
 
    // and then make sure to update the actor's position, as
    // otherwise it looks like we've stopped for 1 frame.
    update();
  }
  
  /**
   * This boundary blocked our path.
   */
  void gotBlocked(Boundary b, float[] intersection, float[] original) {
    // subclasses can implement, but don't have to
  }

  /**
   * collisions may force us to stop this
   * actor's movement. the actor is also
   * moved back by dx/dy
   */
  void stop(float dx, float dy) {
    // we need to prevent IEEE floats polluting
    // the position information, so even though
    // the math is perfect in principle, round
    // the result so that we're not going to be
    // off by 0.0001 or something.
    float resolution = 50;
    x = int(resolution*(x+dx))/resolution;
    y = int(resolution*(y+dy))/resolution;
    ix = 0;
    iy = 0;
    aFrameCount = 0;
  }

  /**
   * Sometimes actors need to be "invulnerable"
   * while going through an animation. This
   * is achieved by setting "interacting" to false
   */
  void setInteracting(boolean _interacting) {
    interacting = _interacting;
  }

  /**
   * set whether or not this actor interacts
   * with the level, or just the player
   */
  void setPlayerInteractionOnly(boolean v ) {
    onlyplayerinteraction = v;
  }

  /**
   * Does this actor temporary not interact
   * with any Interactors? This function
   * is called by the layer level code,
   * and should not be called by anything else.
   */
  boolean isDisabled() {
    if(disabledCounter > 0) {
      disabledCounter--;
      return true;
    }
    return false;
  }

  /**
   * Sometimes we need to bypass interaction for
   * a certain number of frames.
   */
  void disableInteractionFor(int frameCount) {
    disabledCounter = frameCount;
  }

  /**
   * it's possible that an actor
   * has to be removed from the
   * level. If so, we call this method:
   */
  void removeActor() {
    animated = false;
    visible = false;
    states = null;
    active = null;
    remove = true;
  }

  /**
   * Draw preprocessing happens here.
   */
  void draw(float vx, float vy, float vw, float vh) {
    if(!remove) handleInput();
    super.draw(vx,vy,vw,vh);
  }

  /**
   * Can this object be drawn in this viewbox?
   */
  boolean drawableFor(float vx, float vy, float vw, float vh) {
    return true;
  }

  /**
   * Draw this actor.
   */
  void drawObject() {
    if(active!=null) {
      active.draw(disabledCounter>0);
      /*
      if(debug) {
        noFill();
        stroke(255,0,0);
        float[] bounds = getBoundingBox();
        beginShape();
        vertex(bounds[0]-x,bounds[1]-y);
        vertex(bounds[2]-x,bounds[3]-y);
        vertex(bounds[4]-x,bounds[5]-y);
        vertex(bounds[6]-x,bounds[7]-y);
        endShape(CLOSE);
      }
      */
    }
  }

// ====== KEY HANDLING ======

  protected final boolean[] locked = new boolean[256];
  protected final boolean[] keyDown = new boolean[256];
  protected int[] keyCodes = {};

  // if pressed, and part of our known keyset, mark key as "down"
  private void setIfTrue(int mark, int target) {
    if(!locked[target]) {
      if(mark==target) {
        keyDown[target] = true; }}}

  // if released, and part of our known keyset, mark key as "released"
  private void unsetIfTrue(int mark, int target) {
    if(mark==target) {
      locked[target] = false;
      keyDown[target] = false; }}

  // lock a key so that it cannot be triggered repeatedly
  protected void ignore(char key) {
    int keyCode = int(key);
    locked[keyCode] = true;
    keyDown[keyCode] = false; }

  // add a key listener
  protected void handleKey(char key) {
    int keyCode = int(key),
        len = keyCodes.length;
    int[] _tmp = new int[len+1];
    arrayCopy(keyCodes,0,_tmp,0,len);
    _tmp[len] = keyCode;
    keyCodes = _tmp;
  }

  // check whether a key is pressed or not
  protected boolean isKeyDown(char key) {
    int keyCode = int(key);
    return keyDown[keyCode];
  }
  
  protected boolean noKeysDown() {
    for(boolean b: keyDown) { if(b) return false; }
    for(boolean b: locked) { if(b) return false; }
    return true;
  }

  // handle key presses
  void keyPressed(char key, int keyCode) {
    for(int i: keyCodes) {
      setIfTrue(keyCode, i); }}

  // handle key releases
  void keyReleased(char key, int keyCode) {
    for(int i: keyCodes) {
      unsetIfTrue(keyCode, i); }}

  /**
   * Does the indicated x/y coordinate fall inside this drawable thing's region?
   */
  boolean over(float _x, float _y) {
    if (active == null) return false;
    return active.over(_x - getX(), _y - getY());
  }

  void mouseMoved(int mx, int my) {}
  void mousePressed(int mx, int my, int button) {}
  void mouseDragged(int mx, int my, int button) {}
  void mouseReleased(int mx, int my, int button) {}
  void mouseClicked(int mx, int my, int button) {}

// ====== ABSTRACT METHODS ======

  // token implementation
  void handleInput() { }

  // token implementation
  void handleStateFinished(State which) { }

  // token implementation
  void pickedUp(Pickup pickup) { }
}
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
/**
 * Things can listen to boundary collisions for a boundary
 */
interface BoundaryCollisionListener {
  void collisionOccured(Boundary boundary, Actor actor, float[] intersectionInformation);
}/**
 * A bounded interactor is a normal Interactor with
 * one or more boundaries associated with it.
 */
abstract class BoundedInteractor extends Interactor implements BoundaryCollisionListener {
  // the list of associated boundaries
  ArrayList<Boundary> boundaries;

  // are the boundaries active?
  boolean bounding = true;
  
  // simple constructor
  BoundedInteractor(String name) { this(name,0,0); }

  // full constructor
  BoundedInteractor(String name, float dampening_x, float dampening_y) {
    super(name, dampening_x, dampening_y);
    boundaries = new ArrayList<Boundary>();
  }

  // add a boundary
  void addBoundary(Boundary boundary) { 
    boundary.setImpulseCoefficients(ixF,iyF);
    boundaries.add(boundary);
  }
  
  // add a boundary, and register as listener for collisions on it
  void addBoundary(Boundary boundary, boolean listen) {
    addBoundary(boundary);
    boundary.addListener(this);
  }

  // FIXME: make this make sense, because setting 'next'
  //        should only work on open-bounded interactors.
  void setNext(BoundedInteractor next) {
    if(boundaries.size()==1) {
      boundaries.get(0).setNext(next.boundaries.get(0));
    }
  }

  // FIXME: make this make sense, because setting 'previous'
  //        should only work on open-bounded interactors.
  void setPrevious(BoundedInteractor prev) {
    if(boundaries.size()==1) {
      boundaries.get(0).setPrevious(prev.boundaries.get(0));
    }
  }

  // enable all boundaries
  void enableBoundaries() {
    bounding = true;
    for(Boundary b: boundaries) {
      b.enable();
    }
  }

  // disable all boundaries
  void disableBoundaries() {
    bounding = false;
    for(int b=boundaries.size()-1; b>=0; b--) {
      Boundary boundary = boundaries.get(b);
      boundary.disable();
    }
  }
  
  /**
   * We must make sure to remove all
   * boundaries when we are removed.
   */
  void removeActor() {
    disableBoundaries();
    boundaries = new ArrayList<Boundary>();
    super.removeActor();
  }
  
  // draw boundaries
  void drawBoundaries(float x, float y, float w, float h) {
    for(Boundary b: boundaries) {
      b.draw(x,y,w,h);
    }
  }
  
  /**
   * Is something attached to one of our boundaries?
   */
  boolean havePassenger() {
    // no passengers
    return false;
  }
  
  /**
   * listen to collisions on bounded boundaries
   */
  abstract void collisionOccured(Boundary boundary, Actor actor, float[] intersectionInformation);

  // when we update our coordinates, also
  // update our associated boundaries.
  void update() {
    super.update();

    // how much did we actually move?
    float dx = x-previous.x;
    float dy = y-previous.y;
    // if it's not 0, move the boundaries
    if(dx!=0 && dy!=0) {
      for(Boundary b: boundaries) {
        // FIXME: somehow this goes wrong when the
        // interactor is contrained by another
        // boundary, where the actor moves, but the
        // associated boundary for some reason doesn't.
        b.moveBy(dx,dy);
      }
    }
  }
}
/**
 * Alternative collision detection
 */
static class CollisionDetection {
  private static boolean debug = false;

  /**
   * Static classes need global sketch binding
   */
  private static PApplet sketch;
  public static void init(PApplet s) { sketch = s; }


  /**
   * Perform actor/boundary collision detection
   */
  static void interact(Boundary b, Actor a)
  {
    // no interaction if actor was removed from the game.
    if (a.remove) return;
    // no interaction if actor has not moved.
    if (a.x == a.previous.x && a.y == a.previous.y) return;
    float[] correction = blocks(b,a);
    if(correction != null) {
      b.notifyListeners(a, correction);
      a.attachTo(b, correction);
    }
  }


  /**
   * Is this boundary blocking the specified actor?
   */
  static float[] blocks(Boundary b, Actor a)
  {
    float[] current = a.getBoundingBox(),
            previous = a.previous.getBoundingBox(),
            line = {b.x, b.y, b.xw, b.yh};
    return CollisionDetection.getLineRectIntersection(line, previous, current);
  }


  /**
   * Perform line/rect intersection detection. Lines represent boundaries,
   * and rather than doing "normal" line/rect intersection using a
   * "box on a trajectory" that normal actor movement looks like, we pretend
   * the actor box remains stationary, and move the boundary in the opposite
   * direction with the same speed, which gives us a "boundary box", so that
   * we can perform box/box overlap detection instead.
   */
  static float[] getLineRectIntersection(float[] line, float[] previous, float[] current)
  {
    if(debug) sketch.println(sketch.frameCount + " ***");    
    if(debug) sketch.println(sketch.frameCount + ">  testing against: "+arrayToString(line));
    if(debug) sketch.println(sketch.frameCount + ">   previous: "+arrayToString(previous));
    if(debug) sketch.println(sketch.frameCount + ">   current : "+arrayToString(current));

    // First, let's do some dot-product math, to find out whether or not
    // the actor's bounding box is even in range of the boundary.
    float x1=line[0], y1=line[1], x2=line[2], y2=line[3],
          fx = current[0] - previous[0],
          fy = current[1] - previous[1],
          pv=PI/2.0,
          dx = x2-x1,
          dy = y2-y1,
          rdx = dx*cos(pv) - dy*sin(pv),
          rdy = dx*sin(pv) + dy*cos(pv);
          
    // is the delta in a permitted direction? If so, we don't have to do
    // intersection detection because there won't be any.
    float dotproduct = getDotProduct(rdx, rdy, fx, fy);
    if(dotproduct<0) { return null; }

    // then: in-range checks. If not in range, no need to do the more
    //       complicated intersection detections checks.

    // determine range w.r.t. the starting point of the boundary.
    float[] dotProducts_S_P = getDotProducts(x1,y1,x2,y2, previous);
    float[] dotProducts_S_C = getDotProducts(x1,y1,x2,y2, current);

    // determine range w.r.t. the end point of the boundary.
    float[] dotProducts_E_P = getDotProducts(x2,y2,x1,y1, previous);
    float[] dotProducts_E_C = getDotProducts(x2,y2,x1,y1, current);

    // determine 'sidedness', relative to the boundary.
    float[] dotProducts_P = getDotProducts(x1,y1,x1+rdx,y1+rdy, previous);
    float[] dotProducts_C = getDotProducts(x1,y1,x1+rdx,y1+rdy, current);

    // compute the relevant feature values based on the dot products:
    int inRangeSp = 4, inRangeSc = 4,
        inRangeEp = 4, inRangeEc = 4,
        abovePrevious = 0, aboveCurrent = 0;
    for(int i=0; i<8; i+=2) {
      if (dotProducts_S_P[i] < 0) { inRangeSp--; }
      if (dotProducts_S_C[i] < 0) { inRangeSc--; }
      if (dotProducts_E_P[i] < 0) { inRangeEp--; }
      if (dotProducts_E_C[i] < 0) { inRangeEc--; }
      if (dotProducts_P[i] <= 0) { abovePrevious++; }
      if (dotProducts_C[i] <= 0) { aboveCurrent++; }}

    if(debug) sketch.println(sketch.frameCount +">    dotproduct result: start="+inRangeSp+"/"+inRangeSc+", end="+inRangeEp+"/"+inRangeEc+", sided="+abovePrevious+"/"+aboveCurrent);

    // make sure to short-circuit if the actor cannot
    // interact with the boundary because it is out of range.
    boolean inRangeForStart = (inRangeSp == 0 && inRangeSc == 0);
    boolean inRangeForEnd = (inRangeEp == 0 && inRangeEc == 0);
    if (inRangeForStart || inRangeForEnd) {
      if(debug) sketch.println(sketch.frameCount +">   this boundary is not involved in collisions for this frame (out of range).");
      return null;
    }

    // if the force goes against the border's permissible direction, but
    // both previous and current frame actor boxes are above the boundary,
    // then we don't have to bother with intersection detection.
    if (abovePrevious==4 && aboveCurrent==4) {
      if(debug) sketch.println(sketch.frameCount +">   this box is not involved in collisions for this frame (inherently safe 'above' locations).");
      return null;
    } else if(0 < abovePrevious && abovePrevious < 4) {
      if(debug) sketch.println(sketch.frameCount +">   this box is not involved in collisions for this frame (never fully went through boundary).");
      return null;
    }

    // Now then, let's determine whether overlap will occur.
    boolean found = false;

    // We're in bounds: if 'above' is 4, meaning that our previous
    // actor frame is on the blocking side of a boundary,  and
    // 'aboveAfter' is 0, meaning its current frame is on the other
    // side of the boundary, then a collision MUST have occurred.
    if (abovePrevious==4 && aboveCurrent==0) {
      // note that in this situation, the overlap may look
      // like full containment, where the actor's bounding
      // box is fully contained by the boundary's box.
      found = true;
      if(debug) sketch.println(sketch.frameCount +">     collision detected (due to full containment).");
    }

    else {
      // We're in bounds: do box/box intersection checking
      // using the 'previous' box and the boundary-box.
      dx = previous[0] - current[0];
      dy = previous[1] - current[1];

      // form boundary box
      float[] bbox = {line[0], line[1],
                      line[2], line[3],
                      line[2]+dx, line[3]+dy,
                      line[0]+dx, line[1]+dy};

      // do any of the "previous" edges intersect
      // with any of the "boundary box" edges?
      int i,j;
      float[] p = previous, b = bbox, intersection;
      for(i=0; i<8; i+=2) {
        for(j=0; j<8; j+=2) {
          intersection = getLineLineIntersection(p[i], p[i+1], p[(i+2)%8], p[(i+3)%8], b[j], b[j+1], b[(j+2)%8], b[(j+3)%8], false, true);
          if (intersection != null) {
            found = true;
            if(debug) sketch.println(sketch.frameCount +">     collision detected on a box edge (box overlap).");
          }
        }
      }
    }

    // Have we signaled any overlap?
    if (found) {
      float[] distances = getCornerDistances(x1,y1,x2,y2, previous, current);
      int[] corners = rankCorners(distances);

      if(debug) {
        sketch.print(sketch.frameCount + ">      ");
        for(int i=0; i<4; i++) {
          sketch.print(corners[i]+"="+distances[corners[i]]);
          if(i<3) sketch.print(", "); }
        sketch.println();
      }

      // Get the corner on the previous and current actor bounding
      // box that will "hit" the boundary first.
      int corner = 0;
      float xp = previous[corners[corner]],
            yp = previous[corners[corner]+1],
            xc = current[corners[corner]],
            yc = current[corners[corner]+1];

      // The trajectory for this point may intersect with
      // the boundary. If it does, we'll have all the information
      // we need to move the actor back along its trajectory by
      // an amount that will place it "on" the boundary, at the right spot.
      float[] intersection = getLineLineIntersection(xp,yp,xc,yc, x1,y1,x2,y2, false, true);

      if (intersection==null) {
        if(debug) println("nearest-to-boundary is actually not on the boundary itself. More complex math is required!");

        // it's also possible that the first corner to hit the boundary
        // actually never touches the boundary because it intersects only
        // if the boundary is infinitely long. So... let's make that happen:
        intersection = getLineLineIntersection(xp,yp,xc,yc, x1,y1,x2,y2, false, false);

        if (intersection==null) {
          if(debug) println("line extension alone is not enoough...");

          // FIXME: this is not satisfactory! A real solution should be implemented!
          return new float[]{xp-xc, yp-yc}; // effect a full rewind for now
        }

        return new float[]{intersection[0] - xc, intersection[1] - yc};
      }

      // if we get here, there was a normal trajectory
      // intersection with the boundary. Computing the
      // corrective values by which to move the current
      // frame's bounding box is really simple:
      dx = intersection[0] - xc;
      dy = intersection[1] - yc;

      if(debug) sketch.println(sketch.frameCount +">      dx: "+dx+", dy: "+dy);

      return new float[]{dx, dy};
    }

    return null;
  }

  /**
   * For each corner in an object's bounding box, get the distance from its "previous"
   * box to the line defined by (x1,y1,x2,y2). Return this as float[8], corresponding
   * to the bounding box array format.
   */
  static float[] getCornerDistances(float x1, float y1, float x2, float y2, float[] previous, float[] current) {
    float[] distances = {0,0,0,0,0,0,0,0}, intersection;
    float dx, dy;
    for(int i=0; i<8; i+=2) {
      intersection = getLineLineIntersection(x1,y1,x2,y2, previous[i], previous[i+1], current[i], current[i+1], false, false);
      if (intersection == null) {
        continue;
      }
      dx = intersection[0] - previous[i];
      dy = intersection[1] - previous[i+1];
      distances[i] = sqrt(dx*dx+dy*dy);
      distances[i+1] = distances[i];
    }
    return distances;
  }


  /**
   * Get the intersection coordinate between two lines segments,
   * using fairly standard, if a bit lenghty, linear algebra.
   */
  static float[] getLineLineIntersection(float x1, float y1, float x2, float y2, float x3, float y3, float x4, float y4, boolean colinearity, boolean segments)
  {
    float epsilon = 0.1;
    // convert lines to the generatised form [a * x + b + y = c]
    float a1 = -(y2 - y1), b1 = (x2 - x1), c1 = (x2 - x1) * y1 - (y2 - y1) * x1;
    float a2 = -(y4 - y3), b2 = (x4 - x3), c2 = (x4 - x3) * y3 - (y4 - y3) * x3;
    // find their intersection
    float d = a1 * b2 - a2 * b1;
    if (d == 0) {
      // Two lines are parallel: we are not interested in the
      // segment if the points are not colinear.
      if (!colinearity || (x2 - x3) * (y2 - y1) != (y2 - y3) * (x2 - x1)) {
        return null;
      }
      // Solve the algebraic functions [x = (x1 - x0) * t + x0] for t
      float t1 = x3 != x4 ? (x1 - x3) / (x4 - x3) : (y1 - y3) / (y4 - y3);
      float t2 = x3 != x4 ? (x2 - x3) / (x4 - x3) : (y2 - y3) / (y4 - y3);
      if ((t1 < 0 && t2 < 0) || (t1 > 1 && t2 > 1)) {
        // points 1 and 2 are outside the points 3 and 4 segment
        return null;
      }
      // Clamp t values to the interval [0, 1]
      t1 = t1 < 0 ? 0 : t1 > 1 ? 1 : t1;
      t2 = t2 < 0 ? 0 : t2 > 1 ? 1 : t2;
      return new float[]{(x4 - x3) * t1 + x3, (y4 - y3) * t1 + y3,
              (x4 - x3) * t2 + x3, (y4 - y3) * t2 + y3};
    }
    // not colinear - find the intersection point
    else {
      float x = (c1 * b2 - c2 * b1) / d;
      float y = (a1 * c2 - a2 * c1) / d;
      // make sure the point can be found on both segments.
      if (segments && (x < min(x1, x2) - epsilon || max(x1, x2) + epsilon < x ||
                       y < min(y1, y2) - epsilon || max(y1, y2) + epsilon < y ||
                       x < min(x3, x4) - epsilon || max(x3, x4) + epsilon < x ||
                       y < min(y3, y4) - epsilon || max(y3, y4) + epsilon < y)) {
        // not on either, or both, segments.
        return null;
      }
      return new float[]{x, y};
    }
  }


  /**
   * compute the dot product between all corner points of a
   * bounding box, and a boundary line with origin ox/oy
   * and end point tx/ty.
   */
  static float[] getDotProducts(float ox, float oy, float tx, float ty, float[] bbox) {
    float dotx = tx-ox, doty = ty-oy,
          dx, dy, len, dotproduct;

    float[] dotProducts = new float[8];

    for(int i=0; i<8; i+=2) {
      dx = bbox[i]-ox;
      dy = bbox[i+1]-oy;
      dotproduct = getDotProduct(dotx,doty, dx, dy);
      dotProducts[i] = dotproduct;
    }

    return dotProducts;
  }

  /**
   * get the dot product between two vectors
   */
  static float getDotProduct(float dx1, float dy1, float dx2, float dy2) {
    // normalise both vectors
    float l1 = sqrt(dx1*dx1 + dy1*dy1),
          l2 = sqrt(dx2*dx2 + dy2*dy2);
    if (l1==0 || l2==0) return 0;
    dx1 /= l1;
    dy1 /= l1;
    dx2 /= l2;
    dy2 /= l2;
    return dx1*dx2 + dy1*dy2;
  }


  /**
   * Rank the corner points for a bounding box
   * based on it's distance to the boundary,
   * along its trajectory path.
   *
   * We rank by decreasing distance.
   */
  // FIXME: this is a pretty fast code, but there might be
  //        better ways to achieve the desired result.
  static int[] rankCorners(float[] distances) {
    int[] corners = {0,0,0,0};
    float corner1v=999999, corner2v=corner1v, corner3v=corner1v, corner4v=corner1v, distance;
    int   corner1=-1, corner2=-1, corner3=-1, corner4=-1;

    for(int i=0; i<8; i+=2) {
      distance = distances[i];
      if (distance < corner1v) {
        corner4v = corner3v;  corner4 = corner3;
        corner3v = corner2v;  corner3 = corner2;
        corner2v = corner1v;  corner2 = corner1;
        corner1v = distance;  corner1 = i;
        continue; }
      if (distance < corner2v) {
        corner4v = corner3v;  corner4 = corner3;
        corner3v = corner2v;  corner3 = corner2;
        corner2v = distance;  corner2 = i;
        continue; }
      if (distance < corner3v) {
        corner4v = corner3v;  corner4 = corner3;
        corner3v = distance;  corner3 = i;
        continue; }
      corner4v = distance;  corner4 = i;
    }

    // Set up the corners, ranked by
    // proximity to the boundary.
    corners[0] = corner1;
    corners[1] = corner2;
    corners[2] = corner3;
    corners[3] = corner4;
    return corners;
  }


  /**
   * Check if a bounding box's dot product
   * information implies it's safe, or blocked.
   */
  static boolean permitted(float[] dotProducts) {
    for(int i=0; i<8; i+=2) {
      if (dotProducts[i]>0)
        return true; }
    return false;
  }


  /**
   * Perform a coordinate tranlation/rotation so that
   * line (x3/y3, x4/y4) becomes (0/0, .../0), with
   * the other coordinates transformed accordingly
   *
   * returns float[9], with [0]/[1], [2]/[3], [4]/[5] and [6]/[7]
   *                   being four coordinate pairs, and [8] being
   *                   the angle of rotation used by this transform.
   */
  static float[] translateRotate(float x1, float y1, float x2, float y2, float x3, float y3, float x4, float y4, float angle, float cosine, float sine)
  {
    // First, translate all coordinates so that x3/y3 lies on 0/0
    x1 -= x3;   y1 -= y3;
    x2 -= x3;   y2 -= y3;
    x4 -= x3;   y4 -= y3;

    // Rotate (x1'/y1') about (0,0)
    float x1n = x1 * cosine - y1 * sine,
           y1n = x1 * sine + y1 * cosine;

    // Rotate (x2'/y2') about (0,0)
    float x2n = x2 * cosine - y2 * sine,
           y2n = x2 * sine + y2 * cosine;

    // Rotate (x4'/y4') about (0,0)
    float x4n = x4 * cosine - y4 * sine;

    // And then return the transformed coordinates, plus angle used
    return new float[] {x1n, y1n, x2n, y2n, 0, 0, x4n, 0, angle};
  }


  /**
   * Simple drawing helper function
   */
  static void drawBox(float[] boundingbox) {
    sketch.line(boundingbox[0], boundingbox[1], boundingbox[2], boundingbox[3]);
    sketch.line(boundingbox[2], boundingbox[3], boundingbox[4], boundingbox[5]);
    sketch.line(boundingbox[4], boundingbox[5], boundingbox[6], boundingbox[7]);
    sketch.line(boundingbox[6], boundingbox[7], boundingbox[0], boundingbox[1]);
  }

  /**
   * Simple printing helper function
   */
  static String arrayToString(float[] arr) {
    String str = "";
    for(int i=0; i<arr.length; i++) {
      str += int(100*arr[i])/100.0;
      if(i<arr.length-1) { str += ", "; }}
    return str;
  }
}
/**
 * Decals cannot be interacted with in any way.
 * They are things like the number of points on
 * a hit, or the dust when you bump into something.
 * Decals run through one state, and then expire,
 * so they're basically triggered, temporary graphics.
 */
class Decal extends Sprite {

  // indicates whether to kill off this decal
  boolean remove = false;
  
  // indicates whether this is an auto-expiring decal
  boolean expiring = false;

  // indicates how long this decal should live
  protected int duration = -1;
  
  // decals can be owned by something
  Positionable owner = null;

  /**
   * non-expiring constructor
   */
  Decal(String spritesheet, float x, float y) {
    this(spritesheet, x, y, false, -1);
  }
  Decal(String spritesheet, int rows, int columns, float x, float y) {
    this(spritesheet, rows, columns, x, y, false, -1);
  }
  /**
   * expiring constructor
   */
  Decal(String spritesheet, float x, float y, int duration) {
    this(spritesheet, x, y, true, duration);
  }
  Decal(String spritesheet, int rows, int columns, float x, float y, int duration) {
    this(spritesheet, rows, columns, x, y, true, duration);
  }
  
  /**
   * full constructor (1 x 1 spritesheet)
   */
  private Decal(String spritesheet, float x, float y, boolean expiring, int duration) {
    this(spritesheet, 1, 1, x, y, expiring, duration);
  }

  /**
   * full constructor (n x m spritesheet)
   */
  private Decal(String spritesheet, int rows, int columns, float x, float y, boolean expiring, int duration) {
    super(spritesheet, rows, columns);
    setPosition(x,y);
    this.expiring = expiring;
    this.duration = duration;
    if(expiring) { setPath(); }
  }

  /**
   * subclasses must implement the path on which
   * decals travel before they expire
   */
  void setPath() {}
  
  /**
   * decals can be owned, in which case they inherit their
   * position from their owner.
   */
  void setOwner(Positionable owner) {
    this.owner = owner;
  }

  // PREVENT PJS FROM GOING INTO AN ACCIDENTAL HIERARCHY LOOP
  void draw() { super.draw(); }
  void draw(float x, float y) { super.draw(x,y); }

  /**
   * Once expired, decals are cleaned up in Level
   */
  void draw(float vx, float vy, float vw, float vh) {
    if(!expiring || duration-->0) {
      super.draw(); 
    }
    else { 
      remove = true; 
    }
  }
}
/**
 * Any class that implements this interface
 * is able to draw itself ONLY when its visible
 * regions are inside the indicated viewbox.
 */
interface Drawable {
  /**
   * draw this thing, as long as it falls within the drawbox defined by x/y -- x+w/y+h
   */
  void draw(float x, float y, float w, float h);
}
/**
 * This encodes all the boilerplate code
 * necessary for screen drawing and input
 * handling.
 */

// global screens container
HashMap<String, Screen> screenSet;

// global 'currently active' screen
Screen activeScreen = null;

// setup sets up the screen size, and screen container,
// then calls the "initialize" method, which you must
// implement yourself.
void setup() {
  size(screenWidth, screenHeight);
  noLoop();

  screenSet = new HashMap<String, Screen>();
  SpriteMapHandler.init(this);
  SoundManager.init(this);
  CollisionDetection.init(this);
  initialize();
}

// draw loop
void draw() { 
  activeScreen.draw(); 
  SoundManager.draw();
}

// event handling
void keyPressed()    { activeScreen.keyPressed(key, keyCode); }
void keyReleased()   { activeScreen.keyReleased(key, keyCode); }
void mouseMoved()    { activeScreen.mouseMoved(mouseX, mouseY); }
void mousePressed()  { SoundManager.clicked(mouseX,mouseY); activeScreen.mousePressed(mouseX, mouseY, mouseButton); }
void mouseDragged()  { activeScreen.mouseDragged(mouseX, mouseY, mouseButton); }
void mouseReleased() { activeScreen.mouseReleased(mouseX, mouseY, mouseButton); }
void mouseClicked()  { activeScreen.mouseClicked(mouseX, mouseY, mouseButton); }

/**
 * Mute the game
 */
void mute() { SoundManager.mute(true); }

/**
 * Unmute the game
 */
void unmute() { SoundManager.mute(false); }

/**
 * Screens are added to the game through this function.
 */
void addScreen(String name, Screen screen) {
  screenSet.put(name, screen);
  if (activeScreen == null) {
    activeScreen = screen;
    loop();
  } else { SoundManager.stop(activeScreen); }
}

/**
 * We switch between screens with this function.
 *
 * Because we might want to move things from the
 * old screen to the new screen, this function gives
 * you a reference to the old screen after switching.
 */
Screen setActiveScreen(String name) {
  Screen oldScreen = activeScreen;
  activeScreen = screenSet.get(name);
  if (oldScreen != null) {
    oldScreen.cleanUp();
    SoundManager.stop(oldScreen);
  }
  SoundManager.loop(activeScreen);
  return oldScreen;
}

/**
 * Screens can be removed to save memory, etc.
 * as long as they are not the active screen.
 */
void removeScreen(String name) {
  if (screenSet.get(name) != activeScreen) {
    screenSet.remove(name);
  }
}

/**
 * Get a specific screen (for debug purposes)
 */
Screen getScreen(String name) {
  return screenSet.get(name);
}

/**
 * clear all screens
 */
void clearScreens() {
  screenSet = new HashMap<String, Screen>();
  activeScreen = null;
}
/**
 * Interactors are non-player actors
 * that can interact with other interactors
 * as well as player actors. However,
 * they do not interact with pickups.
 */
abstract class Interactor extends Actor {

  // simple constructor
  Interactor(String name) { super(name); }

  // full constructor
  Interactor(String name, float dampening_x, float dampening_y) {
    super(name, dampening_x, dampening_y); }

  /**
   * Can this object be drawn in this viewbox?
   */
  boolean drawableFor(float vx, float vy, float vw, float vh) {
    return persistent || (vx-vw <= x && x <= vx+2*vw && vy-vh <= y && y <=vy+2*vh);
  }

  // Interactors don't do anything with pickups by default
  void pickedUp(Pickup pickup) {}
  
  // Interactors are not playable
  final void handleInput() {}
}
/**
 * JavaScript interface, to enable console.log
 */
interface JSConsole { void log(String msg); }

/**
 * Abstract JavaScript class, containing
 * a console object (with a log() method)
 * and access to window.setPaths().
 */
abstract class JavaScript {
  JSConsole console;
  abstract void loadInEditor(Positionable thing);
  abstract boolean shouldMonitor();
  abstract void updatedPositionable(Positionable thing);
  abstract void reset();
}

/**
 * Local reference to the javascript environment
 */
JavaScript javascript;

/**
 * Binding function used by JavaScript to bind
 * the JS environment to the sketch.
 */
void bindJavaScript(JavaScript js) {
  javascript = js;
}

/**
 * This class defines a generic sprite engine level.
 * A layer may consist of one or more layers, with
 * each layer modeling a 'self-contained' slice.
 * For top-down games, these slices yield pseudo-height,
 * whereas for side-view games they yield pseudo-depth.
 */
abstract class Level extends Screen {
  boolean finished  = false;

  ArrayList<LevelLayer> layers;
  HashMap<String, Integer> layerids;

  // current viewbox
  ViewBox viewbox;

  /**
   * Levels have dimensions!
   */
  Level(float _width, float _height) {
    super(_width,_height);
    layers = new ArrayList<LevelLayer>();
    layerids = new HashMap<String, Integer>();
    viewbox = new ViewBox(_width, _height);
  }

  /**
   * The viewbox only shows part of the level,
   * so that we don't waste time computing things
   * for parts of the level that we can't even see.
   */
  void setViewBox(float _x, float _y, float _w, float _h) {
    viewbox.x = _x;
    viewbox.y = _y;
    viewbox.w = _w;
    viewbox.h = _h;
  }

  void addLevelLayer(String name, LevelLayer layer) {
    layerids.put(name,layers.size());
    layers.add(layer);
  }

  LevelLayer getLevelLayer(String name) {
    return layers.get(layerids.get(name));
  }
  
  void cleanUp() {
    for(LevelLayer l: layers) {
      l.cleanUp();
    }
  }
  
  // FIXME: THIS IS A TEST FUNCTION. KEEP? REJECT?
  void updatePlayer(Player oldPlayer, Player newPlayer) {
    for(LevelLayer l: layers) {
      l.updatePlayer(oldPlayer, newPlayer);
    }
  }

  /**
   * Change the behaviour when the level finishes
   */
  void finish() { setSwappable(); finished = true; }

  /**
   * What to do on a premature level finish (for instance, a reset-warranting death)
   */
  void end() { finish(); }

  /**
   * draw the level, as seen from the viewbox
   */
  void draw() {
    translate(-viewbox.x, -viewbox.y);
    for(LevelLayer l: layers) {
      l.draw();
    }
  }
  
  // used for statistics
  int getActorCount() {
    int count = 0;
    for(LevelLayer l: layers) { count += l.getActorCount(); }
    return count;
  }

  /**
   * passthrough events
   */
  void keyPressed(char key, int keyCode) {
    for(LevelLayer l: layers) {
      l.keyPressed(key, keyCode);
    }
  }

  void keyReleased(char key, int keyCode) {
    for(LevelLayer l: layers) {
      l.keyReleased(key, keyCode);
    }
  }

  void mouseMoved(int mx, int my) {
    for(LevelLayer l: layers) {
      l.mouseMoved(mx, my);
    }
  }

  void mousePressed(int mx, int my, int button) {
    for(LevelLayer l: layers) {
      l.mousePressed(mx, my, button);
    }
  }

  void mouseDragged(int mx, int my, int button) {
    for(LevelLayer l: layers) {
      l.mouseDragged(mx, my, button);
    }
  }

  void mouseReleased(int mx, int my, int button) {
    for(LevelLayer l: layers) {
      l.mouseReleased(mx, my, button);
    }
  }

  void mouseClicked(int mx, int my, int button) {
    for(LevelLayer l: layers) {
      l.mouseClicked(mx, my, button);
    }
  }
  
  // layer component show/hide methods
  void showBackground(boolean b)  { for(LevelLayer l: layers) { l.showBackground = b; }}
  void showBoundaries(boolean b)  { for(LevelLayer l: layers) { l.showBoundaries = b; }}
  void showPickups(boolean b)     { for(LevelLayer l: layers) { l.showPickups = b; }}
  void showDecals(boolean b)      { for(LevelLayer l: layers) { l.showDecals = b; }}
  void showInteractors(boolean b) { for(LevelLayer l: layers) { l.showInteractors = b; }}
  void showActors(boolean b)      { for(LevelLayer l: layers) { l.showActors = b; }}
  void showForeground(boolean b)  { for(LevelLayer l: layers) { l.showForeground = b; }}
  void showTriggers(boolean b)    { for(LevelLayer l: layers) { l.showTriggers = b; }}

}
/**
 * Level layers are intended to regulate both interaction
 * (actors on one level cannot affect actors on another)
 * as well as to effect pseudo-depth.
 *
 * Every layer may contain the following components,
 * drawn in the order listed:
 *
 *  - a background sprite layer
 *  - (actor blocking) boundaries
 *  - pickups (extensions on actors)
 *  - non-players (extensions on actors)
 *  - player actors (extension on actors)
 *  - a foreground sprite layer
 *
 */
abstract class LevelLayer {
  // debug flags, very good for finding out what's going on.
  boolean debug = true,
          showBackground = true,
          showBoundaries = false,
          showPickups = true,
          showDecals = true,
          showInteractors = true,
          showActors = true,
          showForeground = true,
          showTriggers = false;

  // The various layer components
  ArrayList<Boundary> boundaries;
  ArrayList<Drawable> fixed_background, fixed_foreground;
  ArrayList<Pickup> pickups;
  ArrayList<Pickup> npcpickups;
  ArrayList<Decal> decals;
  ArrayList<Interactor> interactors;
  ArrayList<BoundedInteractor> bounded_interactors;
  ArrayList<Player> players;
  ArrayList<Trigger> triggers;

  // Level layers need not share the same coordinate system
  // as the managing level. For instance, things in the
  // background might be rendered smaller to seem farther
  // away, or larger, to create an exxagerated look.
  float xTranslate = 0,
         yTranslate = 0,
         xScale = 1,
         yScale = 1;
   boolean nonstandard = false;

  // Fallback color if a layer has no background color.
  // By default, this color is 100% transparent black.
  color backgroundColor = -1;
  void setBackgroundColor(color c) {
    backgroundColor = c;
  }

  // the list of "collision" regions
  void addBoundary(Boundary boundary)    { boundaries.add(boundary);    }
  void removeBoundary(Boundary boundary) { boundaries.remove(boundary); }
  void clearBoundaries() { boundaries.clear(); }

  // The list of static, non-interacting sprites, building up the background
  void addBackgroundSprite(Drawable fixed)    { fixed_background.add(fixed);    }
  void removeBackgroundSprite(Drawable fixed) { fixed_background.remove(fixed); }
  void clearBackground() { fixed_background.clear(); }

  // The list of static, non-interacting sprites, building up the foreground
  void addForegroundSprite(Drawable fixed)    { fixed_foreground.add(fixed);    }
  void removeForegroundSprite(Drawable fixed) { fixed_foreground.remove(fixed); }
  void clearForeground() { fixed_foreground.clear(); }

  // The list of decals (pure graphic visuals)
  void addDecal(Decal decal)    { decals.add(decal);    }
  void removeDecal(Decal decal) { decals.remove(decal); }
  void clearDecals() { decals.clear(); }

  // event triggers
  void addTrigger(Trigger trigger)    { triggers.add(trigger);    }
  void removeTrigger(Trigger trigger) { triggers.remove(trigger); }
  void clearTriggers() { triggers.clear(); }

  // The list of sprites that may only interact with the player(s) (and boundaries)
  void addForPlayerOnly(Pickup pickup) { pickups.add(pickup); bind(pickup); }
  void removeForPlayerOnly(Pickup pickup) { pickups.remove(pickup); }
  void clearPickups() { pickups.clear(); npcpickups.clear(); }

  // The list of sprites that may only interact with non-players(s) (and boundaries)
  void addForInteractorsOnly(Pickup pickup) { npcpickups.add(pickup); bind(pickup); }
  void removeForInteractorsOnly(Pickup pickup) { npcpickups.remove(pickup); }

  // The list of fully interacting non-player sprites
  void addInteractor(Interactor interactor) { interactors.add(interactor); bind(interactor); }
  void removeInteractor(Interactor interactor) { interactors.remove(interactor); }
  void clearInteractors() { interactors.clear(); bounded_interactors.clear(); }

  // The list of fully interacting non-player sprites that have associated boundaries
  void addBoundedInteractor(BoundedInteractor bounded_interactor) { bounded_interactors.add(bounded_interactor); bind(bounded_interactor); }
  void removeBoundedInteractor(BoundedInteractor bounded_interactor) { bounded_interactors.remove(bounded_interactor); }

  // The list of player sprites
  void addPlayer(Player player) { players.add(player); bind(player); }
  void removePlayer(Player player) { players.remove(player); }
  void clearPlayers() { players.clear(); }

  void updatePlayer(Player oldPlayer, Player newPlayer) {
    int pos = players.indexOf(oldPlayer);
    if (pos > -1) {
      players.set(pos, newPlayer);
      newPlayer.boundaries.clear();
      bind(newPlayer); }}


  // private actor binding
  void bind(Actor actor) { actor.setLevelLayer(this); }
  
  // clean up all transient things
  void cleanUp() {
    cleanUpActors(interactors);
    cleanUpActors(bounded_interactors);
    cleanUpActors(pickups);
    cleanUpActors(npcpickups);
  }
  
  // cleanup an array list
  void cleanUpActors(ArrayList<? extends Actor> list) {
    for(int a = list.size()-1; a>=0; a--) {
      if(!list.get(a).isPersistent()) {
        list.remove(a);
      }
    }
  }
  
  // clear everything except the player
  void clearExceptPlayer() {
    clearBoundaries();
    clearBackground();
    clearForeground();
    clearDecals();
    clearTriggers();
    clearPickups();
    clearInteractors();    
  }

  // clear everything
  void clear() {
    clearExceptPlayer();
    clearPlayers();
  }

  // =============================== //
  //   MAIN CLASS CODE STARTS HERE   //
  // =============================== //
  
  // level layer size
  float width=0, height=0;
  
  // the owning level for this layer
  Level parent;
  
  // level viewbox
  ViewBox viewbox;
  
  /**
   * fallthrough constructor
   */
  LevelLayer(Level p) {
    this(p, p.width, p.height);
  }

  /**
   * Constructor
   */
  LevelLayer(Level p, float w, float h) {
    this.parent = p;
    this.viewbox = p.viewbox;
    this.width = w;
    this.height = h;
    
    boundaries = new ArrayList<Boundary>();
    fixed_background = new ArrayList<Drawable>();
    fixed_foreground = new ArrayList<Drawable>();
    pickups = new ArrayList<Pickup>();
    npcpickups = new ArrayList<Pickup>();
    decals = new ArrayList<Decal>();
    interactors = new ArrayList<Interactor>();
    bounded_interactors = new ArrayList<BoundedInteractor>();
    players  = new ArrayList<Player>();
    triggers = new ArrayList<Trigger>();
  }

  /**
   * More specific constructor with offset/scale values indicated
   */
  LevelLayer(Level p, float w, float h, float ox, float oy, float sx, float sy) {
    this(p,w,h);
    xTranslate = ox;
    yTranslate = oy;
    xScale = sx;
    yScale = sy;
    if(sx!=1) { width /= sx; width -= screenWidth; }
    if(sy!=1) { height /= sy; }
    nonstandard = (xScale!=1 || yScale!=1 || xTranslate!=0 || yTranslate!=0);
  }
  
  /**
   * Get the level this layer exists in
   */
  Level getLevel() {
    return parent;
  }

  // used for statistics
  int getActorCount() {
    return players.size() + bounded_interactors.size() + interactors.size() + pickups.size();
  }

  /**
   * map a "normal" coordinate to this level's
   * coordinate system.
   */
  float[] mapCoordinate(float x, float y) {
    float vx = (x + xTranslate)*xScale,
          vy = (y + yTranslate)*yScale;
    return new float[]{vx, vy};
  }
  
  /**
   * map a screen coordinate to its layer coordinate equivalent.
   */
  float[] mapCoordinateFromScreen(float x, float y) {
    float mx = map(x/xScale,  0,viewbox.w,  viewbox.x,viewbox.x + viewbox.w);
    float my = map(y/yScale,  0,viewbox.h,  viewbox.y,viewbox.y + viewbox.h);    
    return new float[]{mx, my};
  }

  /**
   * map a layer coordinate to its screen coordinate equivalent.
   */
  float[] mapCoordinateToScreen(float x, float y) {
    float mx = (x/xScale - xTranslate);
    float my = (y/yScale - yTranslate);
    mx *= xScale;
    my *= yScale;
    return new float[]{mx, my};
  }

  /**
   * get the mouse pointer, as relative coordinates,
   * relative to the indicated x/y coordinate in the layer.
   */
  float[] getMouseInformation(float x, float y, float mouseX, float mouseY) {
    float[] mapped = mapCoordinateToScreen(x, y);
    float ax = mapped[0], ay = mapped[1];
    mapped = mapCoordinateFromScreen(mouseX, mouseY);
    float mx = mapped[0], my = mapped[1];
    float dx = mx-ax, dy = my-ay,
          len = sqrt(dx*dx + dy*dy);
    return new float[] {dx,dy,len};
  }

  /**
   * draw this level layer.
   */
  void draw() {
    // get the level viewbox and tranform its
    // reference coordinate values.
    float x,y,w,h;
    float[] mapped = mapCoordinate(viewbox.x,viewbox.y);
    x = mapped[0];
    y = mapped[1];
    w = viewbox.w / xScale;
    h = viewbox.h / yScale;
    
    // save applied transforms so far
    pushMatrix();
    // transform the layer coordinates
    translate(viewbox.x-x, viewbox.y-y);
    scale(xScale, yScale);
    // draw all layer components
    if (showBackground) { handleBackground(x,y,w,h); } else { debugfunctions_drawBackground((int)width, (int)height); }
    if (showBoundaries)   handleBoundaries(x,y,w,h);
    if (showPickups)      handlePickups(x,y,w,h);
    if (showInteractors)  handleNPCs(x,y,w,h);
    if (showActors)       handlePlayers(x,y,w,h);
    if (showDecals)       handleDecals(x,y,w,h);
    if (showForeground)   handleForeground(x,y,w,h);
    if (showTriggers)     handleTriggers(x,y,w,h);
    // restore saved transforms
    popMatrix();
  }

  /**
   * Background color/sprites
   */
  void handleBackground(float x, float y, float w, float h) { 
    if (backgroundColor != -1) {
      background(backgroundColor);
    }

    for(Drawable s: fixed_background) {
      s.draw(x,y,w,h);
    }
  }

  /**
   * Boundaries should normally not be drawn, but
   * a debug flag can make them get drawn anyway.
   */
  void handleBoundaries(float x, float y, float w, float h) { 
    // regular boundaries
    for(Boundary b: boundaries) {
      b.draw(x,y,w,h);
    }
    // bounded interactor boundaries
    for(BoundedInteractor b: bounded_interactors) {
      if(b.bounding) {
        b.drawBoundaries(x,y,w,h);
      }
    }
  }

  /**
   * Handle both player and NPC Pickups.
   */
  void handlePickups(float x, float y, float w, float h) { 
    // player pickups
    for(int i = pickups.size()-1; i>=0; i--) {
      Pickup p = pickups.get(i);
      if(p.remove) {
        pickups.remove(i);
        continue; }

      // boundary interference?
      if(p.interacting && p.inMotion && !p.onlyplayerinteraction) {
        for(Boundary b: boundaries) {
          CollisionDetection.interact(b,p); }
        for(BoundedInteractor o: bounded_interactors) {
          if(o.bounding) {
            for(Boundary b: o.boundaries) {
                CollisionDetection.interact(b,p); }}}}

      // player interaction?
      for(Player a: players) {
        if(!a.interacting) continue;
        float[] overlap = a.overlap(p);
        if(overlap!=null) {
          p.overlapOccurredWith(a);
          break; }}

      // draw pickup
      p.draw(x,y,w,h);
    }

    // ---- npc pickups
    for(int i = npcpickups.size()-1; i>=0; i--) {
      Pickup p = npcpickups.get(i);
      if(p.remove) {
        npcpickups.remove(i);
        continue; }

      // boundary interference?
      if(p.interacting && p.inMotion && !p.onlyplayerinteraction) {
        for(Boundary b: boundaries) {
          CollisionDetection.interact(b,p); }
        for(BoundedInteractor o: bounded_interactors) {
          if(o.bounding) {
            for(Boundary b: o.boundaries) {
                CollisionDetection.interact(b,p); }}}}

      // npc interaction?
      for(Interactor a: interactors) {
        if(!a.interacting) continue;
        float[] overlap = a.overlap(p);
        if(overlap!=null) {
          p.overlapOccurredWith(a);
          break; }}

      // draw pickup
      p.draw(x,y,w,h);
    }
  }

  /**
   * Handle both regular and bounded NPCs
   */
  void handleNPCs(float x, float y, float w, float h) {
    handleNPCs(x, y, w, h, interactors);
    handleNPCs(x, y, w, h, bounded_interactors);
  }
  
  /**
   * helper function to prevent code duplication
   */
  void handleNPCs(float x, float y, float w, float h, ArrayList<? extends Interactor> interactors) {
    for(int i = 0; i<interactors.size(); i++) {
      Interactor a = interactors.get(i);
      if(a.remove) {
        interactors.remove(i);
        continue; }

      // boundary interference?
      if(a.interacting && a.inMotion && !a.onlyplayerinteraction) {
        for(Boundary b: boundaries) {
            CollisionDetection.interact(b,a); }
        // boundary interference from bounded interactors?
        for(BoundedInteractor o: bounded_interactors) {
          if(o == a) continue;
          if(o.bounding) {
            for(Boundary b: o.boundaries) {
                CollisionDetection.interact(b,a); }}}}

      // draw interactor
      a.draw(x,y,w,h);
    }
  }

  /**
   * Handle player characters
   */
  void handlePlayers(float x, float y, float w, float h) {
    for(int i=players.size()-1; i>=0; i--) {
      Player a = players.get(i);

      if(a.remove) {
        players.remove(i);
        continue; }

      if(a.interacting) {

        // boundary interference?
        if(a.inMotion) {
          for(Boundary b: boundaries) {
            CollisionDetection.interact(b,a); }

          // boundary interference from bounded interactors?
          for(BoundedInteractor o: bounded_interactors) {
            if(o.bounding) {
              for(Boundary b: o.boundaries) {
                CollisionDetection.interact(b,a); }}}}

        // collisions with other sprites?
        if(!a.isDisabled()) {
          handleActorCollision(x,y,w,h,a,interactors);
          handleActorCollision(x,y,w,h,a,bounded_interactors);
        }

        // has the player tripped any triggers?
        for(int j = triggers.size()-1; j>=0; j--) {
          Trigger t = triggers.get(j);
          if(t.remove) { triggers.remove(t); continue; }
          float[] overlap = t.overlap(a);
          if(overlap==null && t.disabled) {
            t.enable(); 
          }
          else if(overlap!=null && !t.disabled) {
            t.run(this, a, overlap); 
          }
        }
      }

      // draw actor
      a.draw(x,y,w,h);
    }
  }
  
  /**
   * helper function to prevent code duplication
   */
  void handleActorCollision(float x, float y, float w, float h, Actor a, ArrayList<? extends Interactor> interactors) {
    for(int i = 0; i<interactors.size(); i++) {
      Actor o = interactors.get(i);
      if(!o.interacting) continue;
      float[] overlap = a.overlap(o);
      if(overlap!=null) {
        a.overlapOccurredWith(o, overlap);
        int len = overlap.length;
        float[] inverse = new float[len];
        arrayCopy(overlap,0,inverse,0,len);
        for(int pos=0; pos<len; pos++) { inverse[pos] = -inverse[pos]; }
        o.overlapOccurredWith(a, inverse); 
      }
      else if(o instanceof Tracker) {
        ((Tracker)o).track(a, x,y,w,h);
      }
    }
  }

  /**
   * Draw all decals.
   */
  void handleDecals(float x, float y, float w, float h) {
    for(int i=decals.size()-1; i>=0; i--) {
      Decal d = decals.get(i);
      if(d.remove) { decals.remove(i); continue; }
      d.draw(x,y,w,h);
    }
  }

  /**
   * Draw all foreground sprites
   */
  void handleForeground(float x, float y, float w, float h) {
    for(Drawable s: fixed_foreground) {
      s.draw(x,y,w,h);
    }
  }

  /**
   * Triggers should normally not be drawn, but
   * a debug flag can make them get drawn anyway.
   */
  void handleTriggers(float x, float y, float w, float h) {
    for(Drawable t: triggers) {
      t.draw(x,y,w,h);
    }
  }


  /**
   * passthrough events
   */
  void keyPressed(char key, int keyCode) {
    for(Player a: players) {
      a.keyPressed(key,keyCode); }}

  void keyReleased(char key, int keyCode) {
    for(Player a: players) {
      a.keyReleased(key,keyCode); }}

  void mouseMoved(int mx, int my) {
    for(Player a: players) {
      a.mouseMoved(mx,my); }}

  void mousePressed(int mx, int my, int button) {
    for(Player a: players) {
      a.mousePressed(mx,my,button); }}

  void mouseDragged(int mx, int my, int button) {
    for(Player a: players) {
      a.mouseDragged(mx,my,button); }}

  void mouseReleased(int mx, int my, int button) {
    for(Player a: players) {
      a.mouseReleased(mx,my,button); }}

  void mouseClicked(int mx, int my, int button) {
    for(Player a: players) {
      a.mouseClicked(mx,my,button); }}
}
/**
 * Pickups!
 * These are special type of objects that disappear
 * when a player touches them and then make something
 * happen (like change scores or powers, etc).
 */
class Pickup extends Actor {

  String pickup_sprite = "";
  int rows = 0;
  int columns = 0;

  /**
   * Pickups are essentially Actors that mostly do nothing,
   * until a player character runs into them. Then *poof*.
   */
  Pickup(String name, String spr, int r, int c, float x, float y, boolean _persistent) {
    super(name);
    pickup_sprite = spr;
    rows = r;
    columns = c;
    setupStates();
    setPosition(x,y);
    persistent = _persistent;
    alignSprite(CENTER,CENTER);
  }

  /**
   * Pickup sprite animation.
   */
  void setupStates() {
    State pickup = new State(name, pickup_sprite, rows, columns);
    pickup.sprite.setAnimationSpeed(0.25);
    addState(pickup);
  }
  
  // wrapper
  void alignSprite(int halign, int valign) {
    active.sprite.align(halign, valign);
  }

  /**
   * A pickup disappears when touched by a player actor.
   */
  void overlapOccurredWith(Actor other) {
    removeActor();
    other.pickedUp(this);
    pickedUp(other);
  }

  /**
   * Can this object be drawn in this viewbox?
   */
  boolean drawableFor(float vx, float vy, float vw, float vh) {
    boolean drawable = (vx-vw <= x && x <= vx+2*vw && vy-vh <= y && y <=vy+2*vh);
    if(!persistent && !drawable) { removeActor(); }
    return drawable;
  }

  // unused
  final void handleInput() {}

  // unused
  final void handleStateFinished(State which) {}

  // unused
  final void pickedUp(Pickup pickup) {}
  
  // unused, but we can overwrite it
  void pickedUp(Actor by) {}
}

/**
 * Players are player-controllable actors.
 */
abstract class Player extends Actor {

  // simple constructor
  Player(String name) { super(name); }

  // full constructor
  Player(String name, float dampening_x, float dampening_y) {
    super(name, dampening_x, dampening_y); }
}
/**
 * This is a helper class for Positionables,
 * used for recording "previous" frame data
 * in case we need to roll back, or do something
 * that requires multi-frame information
 */
class Position {
  /**
   * A monitoring object for informing JavaScript
   * about the current state of this Positionable.
   */
  boolean monitoredByJavaScript = false;
  void setMonitoredByJavaScript(boolean monitored) { monitoredByJavaScript = monitored; }
  
// ==============
//   variables
// ==============

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

  // which direction is this positionable facing,
  // based on its movement in the last frame?
  // -1 means "not set", 0-2*PI indicates the direction
  // in radians (0 is ->, values run clockwise) 
  float direction = -1;

  // administrative
  boolean animated = true;  // does this object move?
  boolean visible = true;   // do we draw this object?

// ========================
//  quasi-copy-constructor
// ========================

  void copyFrom(Position other) {
    x = other.x;
    y = other.y;
    width = other.width;
    height = other.height;
    hflip  = other.hflip;
    vflip  = other.vflip;
    ox = other.ox;
    oy = other.oy;
    sx = other.sx;
    sy = other.sy;
    r = other.r;
    ix = other.ix;
    iy = other.iy;
    ixF = other.ixF;
    iyF = other.iyF;
    fx = other.fx;
    fy = other.fy;
    ixA = other.ixA;
    iyA = other.iyA;
    aFrameCount = other.aFrameCount;
    direction  = other.direction;
    animated  = other.animated;
    visible  = other.visible;
  }

// ==============
//    methods
// ==============

  /**
   * Get this positionable's bounding box
   */
  float[] getBoundingBox() {
    return new float[]{x+ox-width/2, y-oy-height/2,  // top-left
                       x+ox+width/2, y-oy-height/2,  // top-right
                       x+ox+width/2, y-oy+height/2,  // bottom-right
                       x+ox-width/2, y-oy+height/2}; // bottom-left
  }

  /**
   * Primitive sprite overlap test: bounding box
   * overlap using midpoint distance.
   */
  float[] overlap(Position other) {
    float w=width, h=height, ow=other.width, oh=other.height;
    float[] bounds = getBoundingBox();
    float[] obounds = other.getBoundingBox();
    if(bounds==null || obounds==null) return null;
    
    float xmid1 = (bounds[0] + bounds[2])/2;
    float ymid1 = (bounds[1] + bounds[5])/2;
    float xmid2 = (obounds[0] + obounds[2])/2;
    float ymid2 = (obounds[1] + obounds[5])/2;

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
    float safedx = dw-dx,
          safedy = dh-dy;
    return new float[]{dx, dy, angle, safedx, safedy};
  }

  /**
   * Apply all the transforms to the
   * world coordinate system prior to
   * drawing the associated Positionable
   * object.
   */
  void applyTransforms() {
    // we need to make sure we end our transforms
    // in such a way that integer coordinates lie
    // on top of canvas grid coordinates. Hence
    // all the (int) casting in translations.
    translate((int)x, (int)y);
    if (r != 0) { rotate(r); }
    if(hflip) { scale(-1,1); }
    if(vflip) { scale(1,-1); }
    scale(sx,sy);
    translate((int)ox, (int)oy);
  }

  /**
   * Good old toString()
   */
  String toString() {
    return "position: "+x+"/"+y+
           ", impulse: "+ix+"/"+iy+
           " (impulse factor: "+ixF+"/"+iyF+")" +
           ", forces: "+fx+"/"+fy+
           " (force factor: "+ixA+"/"+iyA+")"+
           ", offset: "+ox+"/"+oy;
  }
}
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
/**
 * Every thing in 2D sprite games happens in "Screen"s.
 * Some screens are menus, some screens are levels, but
 * the most generic class is the Screen class
 */
abstract class Screen {
  // is this screen locked, or can it be swapped out?
  boolean swappable = false;

  // level dimensions
  float width, height;

  /**
   * simple Constructor
   */
  Screen(float _width, float _height) {
    width = _width;
    height = _height;
  }
  
  /**
   * allow swapping for this screen
   */
  void setSwappable() {
    swappable = true; 
  }
 
  /**
   * draw the screen
   */ 
  abstract void draw();
  
  /**
   * perform any cleanup when this screen is swapped out
   */
  abstract void cleanUp();

  /**
   * passthrough events
   */
  abstract void keyPressed(char key, int keyCode);
  abstract void keyReleased(char key, int keyCode);
  abstract void mouseMoved(int mx, int my);
  abstract void mousePressed(int mx, int my, int button);
  abstract void mouseDragged(int mx, int my, int button);
  abstract void mouseReleased(int mx, int my, int button);
  abstract void mouseClicked(int mx, int my, int button);
}
/**
 * A generic, abstract shape class.
 * This class has room to fit anything
 * up to to cubic Bezier curves, with
 * additional parameters for x/y scaling
 * at start and end points, as well as
 * rotation at start and end points.
 */
abstract class ShapePrimitive {
  String type = "unknown";

  // coordinate values
  float x1=0, y1=0, cx1=0, cy1=0, cx2=0, cy2=0, x2=0, y2=0;

  // transforms at the end points
  float sx1=1, sy1=1, sx2=1, sy2=1, r1=0, r2=0;

  // must be implemented by extensions
  abstract void draw();

  // set the scale values for start and end points
  void setScales(float _sx1, float _sy1, float _sx2, float _sy2) {
    sx1=_sx1; sy1=_sy1; sx2=_sx2; sy2=_sy2;
  }

  // set the rotation at start and end points
  void setRotations(float _r1, float _r2) {
    r1=_r1; r2=_r2;
  }

  // generate a string representation of this shape.
  String toString() {
    return type+" "+x1+","+y1+","+cx1+","+cy1+","+cx2+","+cy2+","+x2+","+y2+
           " - "+sx1+","+sy1+","+sx2+","+sy2+","+r1+","+r2;
  }
}

/**
 * This class models a dual-purpose 2D
 * point, acting either as linear point
 * or as tangental curve point.
 */
class Point extends ShapePrimitive {
  // will this behave as curve point?
  boolean cpoint = false;

  // since points have no "start and end", alias the values
  float x, y, cx, cy;

  Point(float x, float y) {
    type = "Point";
    this.x=x; this.y=y;
    this.x1=x; this.y1=y;
  }

  // If we know the next point, we can determine
  // the rotation for the sprite at this point.
  void setNext(float nx, float ny) {
    if (!cpoint) {
      r1 = atan2(ny-y,nx-x);
    }
  }

  // Set the curve control values, and turn this
  // into a curve point (even if it already was)
  void setControls(float cx, float cy) {
    cpoint = true;
    this.cx=(cx-x); this.cy=(cy-y);
    this.cx1=this.cx; this.cy1=this.cy;
    r1 = PI + atan2(y-cy,x-cx);
  }

  // Set the rotation for the sprite at this point
  void setRotation(float _r) {
    r1=_r;
  }

  void draw() {
    // if curve, show to-previous control point
    if (cpoint) {
      line(x-cx,y-cy,x,y);
      ellipse(x-cx,y-cy,3,3);
    }
    point(x,y);
    // if curve, show to-next control point 2
    if (cpoint) {
      line(x,y,x+cx,y+cy);
      ellipse(x+cx,y+cy,3,3);
    }
  }

  // this method gets called during edit mode for setting scale and/or rotation
  boolean over(float mx, float my, int boundary) {
    boolean mainpoint = (abs(x-mx) < boundary && abs(y-my) < boundary);
    return mainpoint || overControl(mx, my, boundary);
  }

  // this method gets called during edit mode for setting rotation
  boolean overControl(float mx, float my, int boundary) {
    return (abs(x+cx-mx) < boundary && abs(y+cy-my) < boundary);
  }
}

/**
 * Generic line class
 */
class Line extends ShapePrimitive {
  // Vanilla constructor
  Line(float x1, float y1, float x2, float y2) {
    type = "Line";
    this.x1=x1; this.y1=y1; this.x2=x2; this.y2=y2;
  }
  // Vanilla draw method
  void draw() {
    line(x1,y1,x2,y2);
  }
}

/**
 * Generic cubic Bezier curve class
 */
class Curve extends ShapePrimitive {
  // Vanilla constructor
  Curve(float x1, float y1, float cx1, float cy1, float cx2, float cy2, float x2, float y2) {
    type = "Curve";
    this.x1=x1; this.y1=y1; this.cx1=cx1; this.cy1=cy1; this.cx2=cx2; this.cy2=cy2; this.x2=x2; this.y2=y2;
  }
  // Vanilla draw method
  void draw() {
    bezier(x1,y1,cx1,cy1,cx2,cy2,x2,y2);
  }
}
/**
 * The SoundManager is a static class that is responsible
 * for handling audio loading and playing. Any audio
 * instructions are delegated to this class. In Processing
 * this uses the Minim library, and in Processing.js it
 * uses the HTML5 <audio> element, wrapped by some clever
 * JavaScript written by Daniel Hodgin that emulates an
 * AudioPlayer object so that the code looks the same.
 */

import ddf.minim.*;
import ddf.minim.signals.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;

static class SoundManager {
  private static PApplet sketch;
  private static Minim minim;

  private static HashMap<Object,AudioPlayer> owners;
  private static HashMap<String,AudioPlayer> audioplayers;

  private static boolean muted = true, draw_controls = false;
  private static float draw_x, draw_y;
  private static PImage mute_overlay, unmute_overlay, volume_overlay;
  
  public static void setDrawPosition(float x, float y) {
    draw_controls = true;
    draw_x = x - volume_overlay.width/2;
    draw_y = y - volume_overlay.height/2;
  }

  /**
   * Set up the sound manager
   */
  static void init(PApplet _sketch) { 
    sketch = _sketch;
    owners = new HashMap<Object,AudioPlayer>();
    mute_overlay = sketch.loadImage("mute.gif");
    unmute_overlay = sketch.loadImage("unmute.gif");
    volume_overlay = (muted ? unmute_overlay : mute_overlay);
    minim = new Minim(sketch); 
    reset();
  }

  /**
   * reset list of owners and audio players
   */
  static void reset() {
    owners = new HashMap<Object,AudioPlayer>();
    audioplayers = new HashMap<String,AudioPlayer>();
  }
  
  /**
   * if a draw position was specified,
   * draw the sound manager's control(s)
   */
  static void draw() {
    if(!draw_controls) return;
    sketch.pushMatrix();
    sketch.resetMatrix();
    sketch.image(volume_overlay, draw_x, draw_y);
    sketch.popMatrix();
  }
  
  /**
   * if a draw position was specified,
   * clicking on the draw region effects mute/unmute.
   */
  static void clicked(int mx, int my) {
    if(!draw_controls) return;
    if(draw_x<=mx && mx <=draw_x+volume_overlay.width && draw_y<=my && my <=draw_y+volume_overlay.height) {
      mute(!muted);
    }
  }

  /**
   * load an audio file, bound to a specific object.
   */
  static void load(Object identifier, String filename) {
    // We recycle audio players to keep the
    // cpu and memory footprint low.
    AudioPlayer player = audioplayers.get(filename);
    if(player==null) {
      player = minim.loadFile(filename);
      if(muted) player.mute();
      audioplayers.put(filename, player); }
    owners.put(identifier, player);
  }

  /**
   * play an object-boud audio file. Note that
   * play() does NOT loop the audio. It will play
   * once, then stop.
   */
  static void play(Object identifier) {
    rewind(identifier);
    AudioPlayer ap = owners.get(identifier);
    if(ap==null) {
      println("ERROR: Error in SoundManager, no AudioPlayer exists for "+identifier.toString());
      return;
    }
    ap.play();
  }

  /**
   * play an object-boud audio file. Note that
   * loop() plays an audio file indefinitely,
   * rewinding and starting from the start of
   * the file until stopped.
   */
  static void loop(Object identifier) {
    rewind(identifier);
    AudioPlayer ap = owners.get(identifier);
    if(ap==null) {
      println("ERROR: Error in SoundManager, no AudioPlayer exists for "+identifier.toString());
      return;
    }
    ap.loop();
  }

  /**
   * Pause an audio file that is currently being played.
   */
  static void pause(Object identifier) {
    AudioPlayer ap = owners.get(identifier);
    if(ap==null) {
      println("ERROR: Error in SoundManager, no AudioPlayer exists for "+identifier.toString());
      return;
    }
    ap.pause();
  }

  /**
   * Explicitly set playback position to 0 for an audio file.
   */
  static void rewind(Object identifier) {
    AudioPlayer ap = owners.get(identifier);
    if(ap==null) {
      println("ERROR: Error in SoundManager, no AudioPlayer exists for "+identifier.toString());
      return;
    }
    ap.rewind();
  }

  /**
   * stop a currently playing or looping audio file.
   */
  static void stop(Object identifier) {
    AudioPlayer ap = owners.get(identifier);
    if(ap==null) {
      println("ERROR: Error in SoundManager, no AudioPlayer exists for "+identifier.toString());
      return;
    }
    ap.pause();
    ap.rewind();
  }
  
  /**
   * mute or unmute all audio. Note that this does
   * NOT pause any of the audio files, it simply
   * sets the volume to zero.
   */
  static void mute(boolean _muted) {
    muted = _muted;
    for(AudioPlayer ap: audioplayers.values()) {
      if(muted) { ap.mute(); }
      else { ap.unmute(); }
    }
    volume_overlay = (muted ? unmute_overlay : mute_overlay);
  }
}
/**
 * Sprites are fixed dimension animated 2D graphics,
 * with separate images for each frame of animation.
 *
 * Sprites can be positioned, transformed (translated,
 * scaled, rotated and flipped), and moved along a
 * path either manually or automatically.
 */
class Sprite extends Positionable {

  State state;
  SpritePath path;
  float halign=0, valign=0;
  float halfwidth, halfheight;
  
  // Sprites have a specific coordinate that acts as "anchor" when multiple
  // sprites are used for a single actor. When swapping sprite A for sprite
  // B, the two coordinates A(h/vanchor) and B(h/vanchor) line up to the
  // same screen pixel.
  float hanchor=0, vanchor=0;

  // frame data
  PImage[] frames;          // sprite frames
  int numFrames=0;          // frames.length cache
  float frameFactor=1;      // determines that frame serving compression/dilation

  boolean hflip = false;   // draw horizontall flipped?
  boolean vflip = false;   // draw vertically flipped?


  // animation properties
  boolean visible = true;  // should the sprite be rendered when draw() is called?
  boolean animated = true; // is this sprite "alive"?
  int frameOffset = 0;      // this determines which frame the sprite synchronises on
  int framesServed = 0;

  /**
   * Shortcut constructor, if the sprite has one frame
   */
  Sprite(String spritefile) {
    this(spritefile, 1, 1, 0, 0);
  }

  /**
   * Shortcut constructor, to build a Sprite directly off of a sprite map image.
   */
  Sprite(String spritefile, int rows, int columns) {
    this(spritefile, rows, columns, 0, 0);
  }

  /**
   * Shortcut constructor, to build a Sprite directly off of a sprite map image.
   */
  Sprite(String spritefile, int rows, int columns, float xpos, float ypos) {
    this(SpriteMapHandler.cutTiledSpritesheet(spritefile, columns, rows, true), xpos, ypos, true);
  }

  /**
   * Full constructor.
   */
  private Sprite(PImage[] _frames, float _xpos, float _ypos, boolean _visible) {
    path = new SpritePath();
    setFrames(_frames);
    visible = _visible;
  }

  /**
   * bind a state to this sprite
   */
  void setState(State _state) {
    state = _state;
  }

  /**
   * Bind sprite frames and record the sprite dimensions
   */
  void setFrames(PImage[] _frames) {
    frames = _frames;
    width = _frames[0].width;
    halfwidth = width/2.0;
    height = _frames[0].height;
    halfheight = height/2.0;
    numFrames = _frames.length;
  }

  /**
   * Get the alpha channel for a pixel
   */
  float getAlpha(float _x, float _y) {
    int x = (int) _x;
    int y = (int) _y;
    PImage frame = frames[currentFrame];
    return alpha(frame.get(x,y));
  }

  /**
   * Get the number of frames for this sprite
   */
  int getFrameCount() {
    return numFrames;
  }

  /**
   * Check whether this sprite is animated
   * (i.e. still has frames left to draw).
   */
  boolean isAnimated() {
    return animated;
  }

  /**
   * Align this sprite, by treating its
   * indicated x/y align values as
   * center point.
   */
  void align(int _halign, int _valign) {
    if(_halign == LEFT)        { halign = halfwidth; }
    else if(_halign == CENTER) { halign = 0; }
    else if(_halign == RIGHT)  { halign = -halfwidth; }
    ox = halign;

    if(_valign == TOP)         { valign = halfheight; }
    else if(_valign == CENTER) { valign = 0; }
    else if(_valign == BOTTOM) { valign = -halfheight; }
    oy = valign;
  }

  /**
   * explicitly set the alignment
   */
  void setAlignment(float x, float y) {
    halign = x;
    valign = y;
    ox = x;
    oy = y;
  }  
  
  /**
   * Indicate the sprite's anchor point
   */
  void anchor(int _hanchor, int _vanchor) {
    if(_hanchor == LEFT)       { hanchor = 0; }
    else if(_hanchor == CENTER) { hanchor = halfwidth; }
    else if(_hanchor == RIGHT)  { hanchor = width; }

    if(_vanchor == TOP)        { vanchor = 0; }
    else if(_vanchor == CENTER) { vanchor = halfheight; }
    else if(_vanchor == BOTTOM) { vanchor = height; }
  }
  
  /**
   * explicitly set the anchor point
   */
  void setAnchor(float x, float y) {
    hanchor = x;
    vanchor = y;
  }

  /**
   * if set, sprites are not rotation-interpolated
   * on paths, even if they're curved.
   */
  void setNoRotation(boolean _noRotation) {
    path.setNoRotation(_noRotation);
  }

  /**
   * Flip all frames for this sprite horizontally.
   */
  void flipHorizontal() {
    hflip = !hflip;
    for(PImage img: frames) {
      img.loadPixels();
      int[] pxl = new int[img.pixels.length];
      int w = int(width), h = int(height);
      for(int x=0; x<w; x++) {
        for(int y=0; y<h; y++) {
          pxl[x + y*w] = img.pixels[((w-1)-x) + y*w]; }}
      img.pixels = pxl;
      img.updatePixels();
    }
  }

  /**
   * Flip all frames for this sprite vertically.
   */
  void flipVertical() {
    vflip = !vflip;
    for(PImage img: frames) {
      img.loadPixels();
      int[] pxl = new int[img.pixels.length];
      int w = int(width), h = int(height);
      for(int x=0; x<w; x++) {
        for(int y=0; y<h; y++) {
          pxl[x + y*w] = img.pixels[x + ((h-1)-y)*w]; }}
      img.pixels = pxl;
      img.updatePixels();
    }
  }

// -- draw methods

  /**
   * Set the frame offset to sync the sprite animation
   * based on a different frame in the frame set.
   */
  void setFrameOffset(int offset) {
    frameOffset = offset;
  }

  /**
   * Set the frame factor for compressing or dilating
   * frame serving. Default is '1'. 0.5 will make the
   * frame serving twice as fast, 2 will make it twice
   * as slow.
   */
  void setAnimationSpeed(float factor) {
    frameFactor = factor;
  }

  /**
   * Set the frame offset to sync the sprite animation
   * based on a different frame in the frame set.
   */
  void setPathOffset(int offset) {
    path.setOffset(offset);
  }

  // private current frame counter
  private int currentFrame;

  /**
   * Get the 'current' sprite frame.
   */
  PImage getFrame() {
    // update sprite based on path frames
    currentFrame = getCurrentFrameNumber();
    if (path.size()>0) {
      float[] pathdata = path.getNextFrameInformation();
      setScale(pathdata[2], pathdata[3]);
      setRotation(pathdata[4]);
      if(state!=null) {
        state.setActorOffsets(pathdata[0], pathdata[1]);
        state.setActorDimensions(width*sx, height*sy, halign*sx, valign*sy);
      } else {
        ox = pathdata[0];
        oy = pathdata[1];
      }
    }
    return frames[currentFrame];
  }

  /**
   * Get the 'current' frame number. If this
   * sprite is no longer alive (i.e. it reached
   * the end of its path), it will return the
   * number for the last frame in the set.
   */
  int getCurrentFrameNumber() {
    if(path.size() > 0 && !path.looping && framesServed == path.size()) {
      if(state!=null) { state.finished(); }
      animated = false;
      return numFrames-1;
    }
    float frame = ((frameCount+frameOffset)*frameFactor) % numFrames;
    framesServed++;
    return (int)frame;
  }

  /**
   * Set up the coordinate transformations
   * and draw the sprite's "current" frame
   * at the correct location.
   */
  void draw() {
    draw(0,0); 
  }

  void draw(float px, float py) {
    if (visible) {
      PImage img = getFrame();
      float imx = x + px + ox - halfwidth,
             imy = y + py + oy - halfheight;
      image(img, imx, imy);
    }
  }
 
  // pass-through/unused
  void draw(float _a, float _b, float _c, float _d) {
    this.draw();
  }

  boolean drawableFor(float _a, float _b, float _c, float _d) { 
    return true; 
  }

  void drawObject() {
    println("ERROR: something called Sprite.drawObject instead of Sprite.draw."); 
  }

  // check if coordinate overlaps the sprite.
  boolean over(float _x, float _y) {
    _x -= ox - halfwidth;
    _y -= oy - halfheight;
    return x <= _x && _x <= x+width && y <= _y && _y <= y+height;
  }
  
// -- pathing informmation

  void reset() {
    if(path.size()>0) {
      path.reset();
      animated = true; }
    framesServed = 0;
    frameOffset = -frameCount;
  }

  void stop() {
    animated=false;
  }

  /**
   * this sprite may be swapped out if it
   * finished running through its path animation.
   */
  boolean mayChange() {
    if(path.size()==0) {
      return true;
    }
    return !animated; }

  /**
   * Set the path loop property.
   */
  void setLooping(boolean v) {
    path.setLooping(v);
  }

  /**
   * Clear path information
   */
  void clearPath() {
    path = new SpritePath();
  }

  /**
   * Add a path point
   */
  void addPathPoint(float x, float y, float sx, float sy, float r, int duration)
  {
    path.addPoint(x, y, sx, sy, r, duration);
  }

  /**
   * Set up a (linear interpolated) path from point [1] to point [2]
   */
  void addPathLine(float x1, float y1, float sx1, float sy1, float r1,
                   float x2, float y2, float sx2, float sy2, float r2,
                   float duration)
  // pointless comment to make the 11 arg functor look slightly less horrible
  {
    path.addLine(x1,y1,sx1,sy1,r1,  x2,y2,sx2,sy2,r2,  duration);
  }

  /**
   * Set up a (linear interpolated) path from point [1] to point [2]
   */
  void addPathCurve(float x1, float y1, float sx1, float sy1, float r1,
                   float cx1, float cy1,
                   float cx2, float cy2,
                    float x2, float y2, float sx2, float sy2, float r2,
                    float duration,
                    float slowdown_ratio)
  // pointless comment to make the 16 arg functor look slightly less horrible
  {
    path.addCurve(x1,y1,sx1,sy1,r1,  cx1,cy1,cx2,cy2,  x2,y2,sx2,sy2,r2,  duration, slowdown_ratio);
  }
}
/**
 * The sprite map handler is responsible for turning sprite maps
 * into frame arrays. Sprite maps are single images with multiple
 * animation frames spaced equally along the x and y axes.
 */
static class SpriteMapHandler {

  // We need a reference to the sketch, because
  // we'll be relying on it for image loading.
  static PApplet globalSketch;

  /**
   * This method must be called before cutTiledSpriteSheet can be used.
   * Typically this involves calling setSketch(this) in setup().
   */
  static void init(PApplet s) {
    globalSketch = s;
  }

  /**
   * wrapper for cutTileSpriteSheet cutting ltr/tb
   */
  static PImage[] cutTiledSpritesheet(String _spritesheet,int widthCount,int heightCount) {
    return cutTiledSpritesheet(_spritesheet, widthCount, heightCount, true);
  }

  /**
   * cut a sheet either ltr/tb or tb/ltr depending on whether leftToRightFirst is true or false, respectively.
   */
  private static PImage[] cutTiledSpritesheet(String _spritesheet, int widthCount, int heightCount, boolean leftToRightFirst) {
    // safety first.
    if (globalSketch == null) {
      println("ERROR: SpriteMapHandler requires a reference to the sketch. Call SpriteMapHandler.setSketch(this) in setup().");
    }

    // load the sprite sheet image
    PImage spritesheet = globalSketch.loadImage(_spritesheet);

    // loop through spritesheet and cut out images
    // this method assumes sprites are all the same size and tiled in the spritesheet
    int spriteCount = widthCount*heightCount;
    int spriteIndex = 0;
    int tileWidth = spritesheet.width/widthCount;
    int tileHeight = spritesheet.height/heightCount;

    // safety first: Processing.js and possibly other
    // implementations may require image preloading.
    if(tileWidth == 0 || tileHeight == 0) {
      println("ERROR: tile width or height is 0 (possible missing image preload for "+_spritesheet+"?)");
    }

    // we have all the information we need. Start cutting
    PImage[] sprites = new PImage[spriteCount];
    int i, j;

    // left to right, moving through the rows top to bottom
    if (leftToRightFirst){
      for (i = 0; i < heightCount; i++){
        for (j =0; j < widthCount; j++){
          sprites[spriteIndex++] = spritesheet.get(j*tileWidth,i*tileHeight,tileWidth,tileHeight);
        }
      }
    }

    // top to bottom, moving through the columns left to right
    else {
      for (i = 0; i < widthCount; i++){
        for (j =0; j < heightCount; j++){
          sprites[spriteIndex++] = spritesheet.get(i*tileWidth,j*tileHeight,tileWidth,tileHeight);
        }
      }
    }

    return sprites;
  }
}
/**
 * This class defines a path along which
 * a sprite is transformed.
 */
class SpritePath {

  // container for all path points
  ArrayList<FrameInformation> data;

  // animation path offset
  int pathOffset = 0;

  // how many path frames have been served yet?
  int servedFrame = 0;

  // is this path cyclical?
  boolean looping = false;
  boolean noRotation = false;

  // private class for frame information
  private class FrameInformation {
    float x, y, sx, sy, r;
    FrameInformation(float _x, float _y, float _sx, float _sy, float _r) {
      x=_x; y=_y; sx=_sx; sy=_sy; r=_r; }
    String toString() {
      return "FrameInformation ["+x+", "+y+", "+sx+", "+sy+", "+r+"]"; }}

  /**
   * constructor
   */
  SpritePath() {
    data = new ArrayList<FrameInformation>();
  }

  /**
   * How many frames are there in this path?
   */
  int size() {
    return data.size();
  }

  /**
   * Check whether this path loops
   */
  boolean isLooping() {
    return looping;
  }

  /**
   * Set this path to looping or terminating
   */
  void setLooping(boolean v) {
    looping = v;
  }

  /**
   * if set, sprites are not rotation-interpolated
   * on paths, even if they're curved.
   */
  void setNoRotation(boolean _noRotation) {
    noRotation = _noRotation;
  }

  /**
   * Add frames based on a single point
   */
  void addPoint(float x, float y, float sx, float sy, float r, int span) {
    FrameInformation pp = new FrameInformation(x,y,sx,sy,r);
    while(span-->0) { data.add(pp); }
  }

  /**
   * Add a linear path section, using {FrameInformation} at frame X
   * to using {FrameInformation} at frame Y. Tweening is based on
   * linear interpolation.
   */
  void addLine(float x1, float y1, float sx1, float sy1, float r1,
               float x2, float y2, float sx2, float sy2, float r2,
               float duration)
  // pointless comment to make the 11 arg functor look slightly less horrible
  {
    float t, mt;
    for (float i=0; i<=duration; i++) {
      t = i/duration;
      mt = 1-t;
      addPoint(mt*x1 + t*x2,
               mt*y1 + t*y2,
               mt*sx1 + t*sx2,
               mt*sy1 + t*sy2,
               (noRotation ? r1 : mt*r1 + t*r2),
               1);
    }
  }

  /**
   * Add a cubic bezir curve section, using {FrameInformation}1 at
   * frame X to using {FrameInformation}2 at frame Y. Tweening is based
   * on an interpolation of linear interpolation and cubic bezier
   * interpolation, using a mix ration indicated by <slowdown_ratio>.
   */
  void addCurve(float x1, float y1, float sx1, float sy1, float r1,
               float cx1, float cy1,
               float cx2, float cy2,
                float x2, float y2, float sx2, float sy2, float r2,
                float duration,
                float slowdown_ratio)
  // pointless comment to make the 16 arg functor look slightly less horrible
  {
    float pt, t, mt, x, y, dx, dy, rotation;
    // In order to perform double interpolation, we need both the
    // cubic bezier interpolation coefficients, which are just 't',
    // and the linear interpolation coefficients, which requires a
    // time reparameterisation of the curve. We get those as follows:
    float[] trp = SpritePathChunker.getTimeValues(x1, y1, cx1, cy1, cx2, cy2, x2, y2, duration);

    // loop through the frames and determine the frame
    // information at each associated time value.
    int i, e=trp.length;
    for (i=0; i<e; i++) {

      // plain [t]
      pt = (float)i/(float)e;

      // time repameterised [t]
      t = trp[i];

      // The actual [t] used depends on the mix ratio. A mix ratio of 1 means sprites slow down
      // along curves based on how strong the curve is, a ration of 0 means the sprite travels
      // at a fixed speed. Anything in between runs at a linear interpolation of the two.
      if (slowdown_ratio==0) {}
      else if (slowdown_ratio==1) { t = pt; }
      else { t = slowdown_ratio*pt + (1-slowdown_ratio)*t; }

      // for convenience, we alias (1-t)
      mt = 1-t;

      // Get the x/y coordinate for this time value:
      x = getCubicBezierValue(x1,cx1,cx2,x2,t,mt);
      y = getCubicBezierValue(y1,cy1,cy2,y2,t,mt);

      // Get the rotation at this coordinate:
      dx = getCubicBezierDerivativeValue(x1,cx1,cx2,x2,t);
      dy = getCubicBezierDerivativeValue(y1,cy1,cy2,y2,t);
      rotation = atan2(dy,dx);

      // NOTE:  if this was a curve based on linear->curve points, the first point will
      // have an incorrect dx/dy of (0,0), because the first control point is equal to the
      // starting coordinate. Instead, we must find dx/dy based on the next [t] value!
      if(i==0 && rotation==0) {
        float nt = trp[1], nmt = 1-nt;
        dx = getCubicBezierValue(x1,cx1,cx2,x2,nt,nmt) - x;
        dy = getCubicBezierValue(y1,cy1,cy2,y2,nt,nmt) - y;
        rotation = atan2(dy,dx); }

      // Now that we have all the frame information, interpolate and move on
      addPoint(x, y, mt*sx1 + t*sx2,  mt*sy1 + t*sy2, (noRotation? r1 : rotation), 1);
    }
  }

  // private cubic bezier value computer
  private float getCubicBezierValue(float v1, float c1, float c2, float v2, float t, float mt) {
    float t2 = t*t;
    float mt2 = mt*mt;
    return mt*mt2 * v1 + 3*t*mt2 * c1 + 3*t2*mt * c2 + t2*t * v2;
  }

  // private cubic bezier derivative value computer
  private float getCubicBezierDerivativeValue(float v1, float c1, float c2, float v2, float t) {
    float tt = t*t, t6 = 6*t, tt9 = 9*tt;
    return c2*(t6 - tt9) + c1*(3 - 12*t + tt9) + (-3 + t6)*v1 + tt*(-3*v1 + 3*v2);
  }

  /**
   * Set the animation path offset
   */
  void setOffset(int offset) {
    pathOffset = offset;
  }

  /**
   * effect a path reset
   */
  void reset() {
    pathOffset = 0;
    servedFrame = 0;
  }

  /**
   * get the next frame's pathing information
   */
  float[] getNextFrameInformation() {
    int frame = pathOffset + servedFrame++;
    if(frame<0) { frame = 0; }
    else if(!looping && frame>=data.size()) { frame = data.size()-1; }
    else { frame = frame % data.size(); }
    FrameInformation pp = data.get(frame);
    return new float[]{pp.x, pp.y, pp.sx, pp.sy, pp.r};
  }

  /**
   * String representation for this path
   */
  String toString() {
    String s = "";
    for(FrameInformation p: data) { s += p.toString() + "\n"; }
    return s;
  }

  /**
   * This function is really more for debugging than anything else.
   * It will render the entire animation path without any form of
   * caching, so it can drive down framerates by quite a bit.
   */
  void draw() {
    if(data.size()==0) return;
    ellipseMode(CENTER);
    FrameInformation cur, prev = data.get(0);
    for(int i=0; i<data.size(); i++) {
      cur = data.get(i);
      line(prev.x,prev.y, cur.x, cur.y);
      ellipse(cur.x,cur.y,5,5);
      prev = cur;
    }
  }
}
/**
 * The Sprite path chunker is capable of taking a curved
 * path over X frames, and return the list of coordinates
 * on that curve that correspond to X-1 equidistant segments.
 *
 * It uses the Legendre-Gauss quadrature algorithm for
 * finding the approximate arc length of a curves, which
 * is incredibly fast, and ridiculously accurate at n=25
 *
 */
static class SpritePathChunker {

  // Legendre-Gauss abscissae for n=25
  static final float[] Tvalues = {-0.0640568928626056299791002857091370970011,
                       0.0640568928626056299791002857091370970011,
                      -0.1911188674736163106704367464772076345980,
                       0.1911188674736163106704367464772076345980,
                      -0.3150426796961633968408023065421730279922,
                       0.3150426796961633968408023065421730279922,
                      -0.4337935076260451272567308933503227308393,
                       0.4337935076260451272567308933503227308393,
                      -0.5454214713888395626995020393223967403173,
                       0.5454214713888395626995020393223967403173,
                      -0.6480936519369755455244330732966773211956,
                       0.6480936519369755455244330732966773211956,
                      -0.7401241915785543579175964623573236167431,
                       0.7401241915785543579175964623573236167431,
                      -0.8200019859739029470802051946520805358887,
                       0.8200019859739029470802051946520805358887,
                      -0.8864155270044010714869386902137193828821,
                       0.8864155270044010714869386902137193828821,
                      -0.9382745520027327978951348086411599069834,
                       0.9382745520027327978951348086411599069834,
                      -0.9747285559713094738043537290650419890881,
                       0.9747285559713094738043537290650419890881,
                      -0.9951872199970213106468008845695294439793,
                       0.9951872199970213106468008845695294439793};

  // Legendre-Gauss weights for n=25
  static final float[] Cvalues = {0.1279381953467521593204025975865079089999,
                      0.1279381953467521593204025975865079089999,
                      0.1258374563468283025002847352880053222179,
                      0.1258374563468283025002847352880053222179,
                      0.1216704729278033914052770114722079597414,
                      0.1216704729278033914052770114722079597414,
                      0.1155056680537255991980671865348995197564,
                      0.1155056680537255991980671865348995197564,
                      0.1074442701159656343712356374453520402312,
                      0.1074442701159656343712356374453520402312,
                      0.0976186521041138843823858906034729443491,
                      0.0976186521041138843823858906034729443491,
                      0.0861901615319532743431096832864568568766,
                      0.0861901615319532743431096832864568568766,
                      0.0733464814110802998392557583429152145982,
                      0.0733464814110802998392557583429152145982,
                      0.0592985849154367833380163688161701429635,
                      0.0592985849154367833380163688161701429635,
                      0.0442774388174198077483545432642131345347,
                      0.0442774388174198077483545432642131345347,
                      0.0285313886289336633705904233693217975087,
                      0.0285313886289336633705904233693217975087,
                      0.0123412297999872001830201639904771582223,
                      0.0123412297999872001830201639904771582223};

  /**
   * Naive time parameterisation based on frame duration.
   * 1) calculate total length of curve
   * 2) calculate required equidistant segment length
   * 3) run through curve using small time interval
   *    increments and record at which [t] a new segment
   *    starts.
   * 4) the resulting list is our time parameterisation.
   */
  static float[] getTimeValues(float x1, float y1, float x2, float y2, float x3, float y3, float x4, float y4, float frames) {
    float curvelen = computeCubicCurveLength(1.0,x1,y1,x2,y2,x3,y3,x4,y4),
          seglen = curvelen/frames,
          seglen10 = seglen/10,
          t,
          increment=0.01,
          curlen = 0,
          prevlen = 0;

    // before we do the real run, find an appropriate t increment
    while (computeCubicCurveLength(increment,x1,y1,x2,y2,x3,y3,x4,y4) > seglen10) {
      increment /= 2.0;
    }

    // now that we have our step value, we simply run through the curve:
    int alen = (int)frames;
    float len[] = new float[alen];
    float trp[] = new float[alen];
    int frame = 1;
    for (t = 0; t < 1.0 && frame<alen; t += increment) {
      // get length of curve over interval [0,t]
      curlen = computeCubicCurveLength(t,x1,y1,x2,y2,x3,y3,x4,y4);

      // Did we run past the acceptable segment length?
      // If so, record this [t] as starting a new segment.
      while(curlen > frame*seglen) {
        len[frame] = curlen;
        trp[frame++] = t;
        prevlen = curlen;
      }
    }

    // Make sure that any gaps left at the end of the path are filled with 1.0
    while(frame<alen) { trp[frame++] = 1.0; }
    return trp;
  }

  /**
   * Gauss quadrature for cubic Bezier curves. See
   *
   *   http://processingjs.nihongoresources.com/bezierinfo/#intoffsets_gss
   *
   * for a more detailed explanation on why this is
   * the right way to compute the arc length of a curve.
   */
  private static float computeCubicCurveLength(float z, float x1, float y1, float x2, float y2, float x3, float y3, float x4, float y4)
  {
    float sum = 0;
    int tlen = Tvalues.length;
    float z2 = z/2.0;  // interval-correction
    for(int i=0; i<tlen; i++) {
      float corrected_t = z2 * Tvalues[i] + z2;
      sum += Cvalues[i] * f(corrected_t,x1,y1,x2,y2,x3,y3,x4,y4); }
    return z2 * sum;
  }

  /**
   * This function computes the value of the function
   * that we're trying to compute the discrete integral
   * for (because we can't compute it symbolically).
   */
  private static float f(float t, float x1, float y1, float x2, float y2, float x3, float y3, float x4, float y4)
  {
    float xbase = ddtsqr(t,x1,x2,x3,x4);
    float ybase = ddtsqr(t,y1,y2,y3,y4);
    float combined = xbase*xbase + ybase*ybase;
    return sqrt(combined);
  }

  /**
   * This function computes (d/dt)² for the cubic Bezier function.
   */
  private static float ddtsqr(float t, float p1, float p2, float p3, float p4)
  {
    float t1 = -3*p1 + 9*p2 - 9*p3 + 3*p4;
    float t2 = t*t1 + 6*p1 - 12*p2 + 6*p3;
    return t*t2 - 3*p1 + 3*p2;
  }
}
/**
 * A sprite state is mostly a thin wrapper
 */
class State {
  String name;
  Sprite sprite;
  Actor actor;
  int duration = -1,
      served = 0;

  // this point is considered the "center point" when
  // swapping between states. If a state has an anchor
  // at (3,3), mapping to world coordinate (240,388)
  // and it swaps for a state that has (10,10) as anchor,
  // the associated actor is moved (-7,-7) to effect
  // the anchor being in the same place before and after.
  float ax, ay;

  // shortcut constructor
  State(String name, String spritesheet) {
    this(name, spritesheet, 1, 1);
  }

  // bigger shortcut constructor
  State(String _name, String spritesheet, int rows, int cols) {
    name = _name;
    sprite = new Sprite(spritesheet, rows, cols);
    sprite.setState(this);
  }

  /**
   * add path points to a state
   */
  void addPathPoint(float x, float y, int duration) { sprite.addPathPoint(x, y, 1,1,0, duration); }

  /**
   * add path points to a state (explicit scale and rotations)
   */
  void addPathPoint(float x, float y, float sx, float sy, float r, int duration) { sprite.addPathPoint(x, y, sx, sy, r, duration); }

  /**
   * add a linear path to the state
   */
  void addPathLine(float x1, float y1, float x2, float y2, float duration) {
    sprite.addPathLine(x1,y1,1,1,0,  x2,y2,1,1,0,  duration); }

  /**
   * add a linear path to the state (explicit scale and rotations)
   */
  void addPathLine(float x1, float y1, float sx1, float sy1, float r1,
                   float x2, float y2, float sx2, float sy2, float r2,
                   float duration) {
    sprite.addPathLine(x1,y1,sx1,sy1,r1,  x2,y2,sx2,sy2,r2,  duration); }

  /**
   * add a curved path to the state
   */
  void addPathCurve(float x1, float y1,  float cx1, float cy1,  float cx2, float cy2,  float x2, float y2, float duration, float slowdown_ratio) {
    sprite.addPathCurve(x1,y1,1,1,0,  cx1,cy1,cx2,cy2,  x2,y2,1,1,0,  duration, slowdown_ratio); }

  /**
   * add a curved path to the state (explicit scale and rotations)
   */
  void addPathCurve(float x1, float y1, float sx1, float sy1, float r1,
                   float cx1, float cy1,
                   float cx2, float cy2,
                    float x2, float y2, float sx2, float sy2, float r2,
                    float duration,
                    float slowdown_ratio) {
    sprite.addPathCurve(x1,y1,sx1,sy1,r1,  cx1,cy1,cx2,cy2,  x2,y2,sx2,sy2,r2,  duration, slowdown_ratio); }

  /**
   * incidate whether or not this is a looping path
   */
  void setLooping(boolean l) {
    sprite.setLooping(l);
  }

  /**
   * Make this state last X frames.
   */
  void setDuration(float _duration) {
    setLooping(false);
    duration = (int) _duration;
  }

  /**
   * bind this state to an actor
   */
  void setActor(Actor _actor) {
    actor = _actor;
    actor.width = sprite.width;
    actor.height = sprite.height;
  }

  /**
   * when the sprite is moved by its path,
   * let the actor know of its updated position.
   */
  void setActorOffsets(float x, float y) {
    actor.setTranslation(x, y);
  }

  void setActorDimensions(float w, float h, float xa, float ya) {
    actor.width = w;
    actor.height = h;
    actor.halign = xa;
    actor.valign = ya;
  }

  // reset a sprite (used when swapping states)
  void reset() { 
    sprite.reset();
    served = 0;
  }

  // signal to the actor that the sprite is done running its path
  void finished() {
    if(actor!=null) {
      actor.handleStateFinished(this); }}

  // if the sprite has a non-looping path: is it done running that path?
  boolean mayChange() {
    if (duration != -1) {
      return false;
    }
    return sprite.mayChange(); 
  }

  // drawing the state means draw the sprite
  void draw(boolean disabled) {
    // if disabled, only draw every other frame
    if(disabled && frameCount%2==0) {}
    //otherwise, draw all frames
    else { sprite.draw(0,0); }
    served++; 
    if(served == duration) {
      finished();
    }
  }
  
  // check if coordinate is in sprite
  boolean over(float _x, float _y) {
    return sprite.over(_x,_y);
  }
  
  // set sprite's animation
  void setAnimationSpeed(float factor) {
    sprite.setAnimationSpeed(factor);
  }
}
/**
 * Tiling sprite
 */
class TilingSprite extends Positionable {
  Sprite sprite;

  // from where to where?
  float x1, y1, x2, y2;

  /**
   * Set up a sprite to be tiled from x1/y1 to x2/y2 from file
   */
  // FIXME: temporarily commented off, because of a possible bug in Pjs
//  TilingSprite(String spritesheet, float minx, float miny, float maxx, float maxy) {
//    this(new Sprite(spritesheet),minx,miny,maxx,maxy);
//  }

  /**
   * Set up a sprite to be tiled from x1/y1 to x2/y2 from Sprite
   */
  TilingSprite(Sprite _sprite, float minx, float miny, float maxx, float maxy) {
    x1 = minx;
    y1 = miny;
    x2 = maxx;
    y2 = maxy;
    _sprite.align(LEFT, TOP);
    sprite = _sprite;
  }
  
  /**
   * draw this sprite repretitively
   */
  void draw(float vx, float vy, float vw, float vh) {
    // FIXME: we should know what the viewbox transform
    //        is at this point, because it matters for
    //        determining how many sprite blocks to draw.
    float ox = sprite.x, oy = sprite.y, x, y,
          sx = max(x1, vx - (vx-x1)%sprite.width),
          sy = max(y1, vy - (vy-y1)%sprite.height),
          ex = min(x2, vx+2*vw), // ideally, this is vx + vw + {something that ensures the rightmost block is drawn}
          ey = min(y2, vy+2*vh); // ideally, this is vy + vh + {something that ensures the bottommost block is drawn}
    for(x = sx; x < ex; x += sprite.width){
      for(y = sy; y < ey; y += sprite.height){
        sprite.draw(x,y);
      }
    }
  }

  /**
   * Can this object be drawn in this viewbox?
   */
  boolean drawableFor(float vx, float vy, float vw, float vh) {
    // tile drawing will short circuit based on the viewbox.
    return true;
  }

  // unused for tiling sprites
  void drawObject() {}
}
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
/**
 * Triggers can make things happen in levels.
 * They define a region through which a player
 * Actor has to pass for it to trigger.
 */
abstract class Trigger extends Positionable {
  // does this trigger need removing? is it enabled?
  boolean remove = false, disabled = false;
  
  String triggername="";
  
  Trigger(String name) {
    triggername = name;  
  }

  Trigger(String name, float x, float y, float w, float h) {
    super(x,y,w,h);
    triggername = name;
  }
  
  void setArea(float x, float y, float w, float h) {
    setPosition(x,y);
    width = w;
    height = h;
  }

  boolean drawableFor(float x, float y, float w, float h) {
    return x<=this.x+width && this.x<=x+w && y<=this.y+height && this.y<=y+h;
  }
  
  void drawObject() {
    stroke(255,127,0,150);
    fill(255,127,0,150);
    rect(-width/2,height/2,width,height);
    fill(0);
    textSize(12);
    float tw = textWidth(triggername);
    text(triggername,-5-tw,height);
  }
  
  void enable() { disabled = false; }
  void disable() { disabled = true; }
  void removeTrigger() { remove = true; }

  abstract void run(LevelLayer level, Actor actor, float[] intersection);
}
/**
 * Possible the simplest class...
 * A viewbox simply defines a region of
 * interest that is used for render limits.
 * Anything outside the viewbox is not drawn,
 * (although it might still interact), and
 * anything inside the viewbox is shown.
 */
class ViewBox {

  // viewbox values
  float x=0, y=0, w=0, h=0;
  
  ViewBox() {}
  ViewBox(float _w, float _h) { w = _w; h = _h; }
  ViewBox(float _x, float _y, float _w, float _h) { x = _x; y = _y; w = _w; h = _h; }
  String toString() { return x+"/"+y+" - "+w+"/"+h; }

  // current layer transform values
  float llox=0, lloy=0, llsx=1, llsy=1;

  // ye olde getterse
  float getX()      { return x-llox; }
  float getY()      { return y-lloy; }
  float getWidth()  { return w*llsx; }
  float getHeight() { return h*llsy; }

  // the level layer transforms for the layer
  // that the viewbox is currently used by,
  // to determine whether or not to draw things
  // because they are "in view" or not
  void setLevelLayer(LevelLayer layer) {
    if (layer.nonstandard) {
      llox = layer.xTranslate;
      lloy = layer.yTranslate;
      llsx = layer.xScale;
      llsy = layer.yScale;
    }
  }

  /**
   * Reposition the viewbox, based on where
   * our main actor is located on the screen.
   * We need to make sure we never make the
   * viewbox run past the level edges, and
   * in order to make sure of that, we need
   * to transfrom the actor's coordinates
   * to screen coordinates, based on the
   * coordinate transform for the level layer
   * the actor is in.
   */
  void track(Level level, Actor who) {
    setLevelLayer(who.getLevelLayer());

    // FIXME: This does not work quite right!
    //        We leave things as they are so
    //        actors are positioned at scale*midpoint

    // Get actor coordinates, transformed to screen
    // coordinates, and forced to integer values.
    float ax = round(who.getX()),
          ay = round(who.getY());

    // Ideally the actor is in the center of the viewbox,
    // but the level edges may require different positioning.
    float idealx = ax - w/2,
          idealy = ay - h/2;

    // set values based on visual constraints
    x = min( max(0,idealx), level.width - w );
    y = min( max(0,idealy), level.height - h );
  }
}


  /**
   * Debug function for drawing bounding boxes to the screen.
   */
  static void debugfunctions_drawBoundingBox(float[] bounds, PApplet sketch) {
    sketch.stroke(255,0,0);
    sketch.fill(0,50);
    sketch.beginShape();
    for(int i=0, last=bounds.length; i<last; i+=2) {
      sketch.vertex(bounds[i],bounds[i+1]);
    }
    sketch.endShape(CLOSE); 
  }


  /**
   * Draw a nice looking grid
   */
  void debugfunctions_drawBackground(float width, float height) {
    background(255,255,252);
    strokeWeight(1);
    fill(0);
    // fine grid
    stroke(235);
    float x, y;
    for (x = -width; x < width; x += 10) {
      line(x,-height,x,height); }
    for (y = -height; y < height; y += 10) {
      line(-width,y,width,y); }
    // coarse grid
    stroke(208);
    for (x = -width; x < width; x += 100) {
      line(x,-height,x,height); }
    for (y = -height; y < height; y += 100) {
      line(-width,y,width,y); }
    // reset to black
    stroke(0);
  }
/**
 * Draw a nice looking grid
 */
void drawBackground(float width, float height) {
  background(255,255,252);
  strokeWeight(1);
  fill(0);
  // fine grid
  stroke(235);
  float x, y;
  for (x = -width; x < width; x += 10) {
    line(x,-height,x,height); }
  for (y = -height; y < height; y += 10) {
    line(-width,y,width,y); }
  // coarse grid
  stroke(208);
  for (x = -width; x < width; x += 100) {
    line(x,-height,x,height); }
  for (y = -height; y < height; y += 100) {
    line(-width,y,width,y); }
  // reset to black
  stroke(0);
}
/***********************************
 *                                 *
 *     This file does nothing,     *
 *    but allows Processing to     *
 *     actually load the code      *
 *    if located in a directory    *
 *     of the same name. Feel      *
 *       free to rename it.        * 
 *                                 *
 ***********************************/
 

/* @ p j s  preload="docs/tutorial/graphics/mario/small/Standing-mario.gif"; */

/*

final int screenWidth = 512;
final int screenHeight = 432;
void initialize() { 
  addScreen("test", new TestLevel(width,height)); 
}

class TestLevel extends Level {
  TestLevel(float w, float h) {
    super(w,h); 
    addLevelLayer("test", new TestLayer(this));
  }
  
  void draw() {
    fill(0,10);
    rect(-1,-1,width+2,height+2);
    super.draw();
  }
}

class TestLayer extends LevelLayer {
  TestObject t1;
  
  TestLayer(Level p) {
    super(p,p.width,p.height); 
    showBoundaries = true;
    
    int v = 10;

    t1 = new TestObject(width/2+v/2, height/2-210);
    t1.setForces(5,0);
    
    t1.setForces(0,0.01);
    t1.setAcceleration(0,0.1);

    addPlayer(t1);

    addBoundary(new Boundary(width/2+230,height,width/2+200,0));
    addBoundary(new Boundary(width/2-180,0,width/2-150,height));   
    addBoundary(new Boundary(width,height/2-200,0,height/2-120));
    addBoundary(new Boundary(0,height/2+200,width,height/2+120));

    //addBoundary(new Boundary(width/2,height/2,width/2 + v,height/2));
  }

  void draw() {
    super.draw();
    viewbox.track(parent,t1);
  }
}

class TestObject extends Player {
  boolean small = true;
  
  TestObject(float x, float y) {
    super("test");
    addState(new State("test","docs/tutorial/graphics/mario/small/Standing-mario.gif"));
    setPosition(x,y);
    Decal attachment = new Decal("static.gif",width,0);
    addDecal(attachment);
  }
  
  void addState(State s) {
    s.sprite.anchor(CENTER, BOTTOM);
    super.addState(s);
  }
  
  void keyPressed(char key, int keyCode) {
    if(small) {
      addState(new State("test","docs/tutorial/graphics/mario/big/Standing-mario.gif"));
    }
    else {
      addState(new State("test","docs/tutorial/graphics/mario/small/Standing-mario.gif"));
    }
    small = !small; 
  }
}

*/
