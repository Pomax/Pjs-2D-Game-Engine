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
    Computer.actors();
    name = _name;
    states = new HashMap<String, State>();
    Computer.hashmaps("String","State");
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
    states.put(state.name, state);
    active = state;
    updatePositioningInformation();
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
    if (tmp!=active) {
      tmp.reset();
      boolean hflip = (active.sprite!=null ? active.sprite.hflip : false),
               vflip = (active.sprite!=null ? active.sprite.vflip : false);
      active = tmp;
      if(active.sprite!=null) {
        if(hflip) active.sprite.flipHorizontal();
        if(vflip) active.sprite.flipVertical();
        updatePositioningInformation();
      }
    }
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
   * attach an actor to a boundary, so that
   * impulse is redirected along boundary
   * surfaces.
   */  
  void attachTo(Boundary boundary, float[] correction) {
    // record attachment
    boundaries.add(boundary);

    // stop the actor
    float ix = this.ix - (fx*ixF),
          iy = this.iy - (fy*iyF);
    stop(correction[0], correction[1]);

    // then impart a new impulse, as redirected by the boundary.
    float[] rdf = boundary.redirectForce(ix, iy);
    addImpulse(rdf[0], rdf[1]);

    // finally, call the blocked handler
    gotBlocked(boundary, correction);
  }
  
  /**
   * This boundary blocked our path.
   */
  void gotBlocked(Boundary b, float[] intersection) {
    // subclasses can implement, but don't have to
  }

  /**
   * collisions may force us to stop this
   * actor's movement. the actor is also
   * moved back by dx/dy
   */
  void stop(float dx, float dy) {
    x = round(x+dx);
    y = round(y+dy);
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
   * with any Interactors?
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
      active.draw();
      /*
      if(debug) {
        pushMatrix();
        resetMatrix();
        noFill();
        stroke(255,0,0);
        float[] bounds = getBoundingBox();
        beginShape();
        vertex(bounds[0],bounds[1]);
        vertex(bounds[2],bounds[3]);
        vertex(bounds[4],bounds[5]);
        vertex(bounds[6],bounds[7]);
        endShape(CLOSE); 
        fill(255,0,0);
        ellipse(bounds[0],bounds[1],5,5);
        ellipse((bounds[0]+bounds[2]+bounds[4]+bounds[6])/4,(bounds[1]+bounds[3]+bounds[5]+bounds[7])/4,5,5);
        popMatrix();
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
  protected void ignore(int keyCode) {
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

  // handle key presses
  void keyPressed(char key, int keyCode) {
    for(int i: keyCodes) {
      setIfTrue(keyCode, i); }}

  // handle key releases
  void keyReleased(char key, int keyCode) {
    for(int i: keyCodes) {
      unsetIfTrue(keyCode, i); }}

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
    float[] bbox = thing.getBoundingBox(), nbox = new float[8];

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

/**
 * A bounded interactor is a normal Interactor with
 * one or more boundaries associated with it.
 */
abstract class BoundedInteractor extends Interactor {
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
    Computer.arraylists("Boundary");
  }

  // add a boundary
  void addBoundary(Boundary boundary) { 
    boundary.setImpulseCoefficients(ixF,iyF);
    boundaries.add(boundary); 
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
 * Collision detection is a complicated thing.
 * In order not to pollute the Boundary class,
 * it's handled by this static computing class.
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
    if (a.isAttachedTo(b)) { return; }

    float[] bbox = a.getBoundingBox(),
             correction = blocks(b,a,bbox);

    if(correction != null) {
      //adjustForSpriteMask(b, a, bbox, correction);
      a.attachTo(b, correction); 
    }
  }


  /**
   * Is this boundary blocking the specified actor?
   *
   * @return null if no intersect, otherwise float[3]
   *         indices: [0] = dx, [1] = dy, [2] = bbox (x) index to hit boundary first   
   */
  static float[] blocks(Boundary b, Actor a, float[] bbox)
  {
    // we don't block in the pass-through direction.
    if(b.allowPassThrough(a.ix, a.iy)) { return null; }

    float[] current = bbox,
            previous = a.previous.getBoundingBox(),
            line = {b.x, b.y, b.xw, b.yh};

    return CollisionDetection.getLineRectIntersection(line, current, previous);
  }


  /**
   * The correction moves the bounding box to a safe location on the boundary,
   * but this might not be the correct location given the sprite inside the
   * bounding box. In order to make things look 'right', we examine the bounding
   * box to see by how much we can decrease the correction so that it looks as
   * if the sprite is anchored to the boundary.
   *
   * Does not return anything. The correction array is modified in-place.
   */
  static void adjustForSpriteMask(Boundary b, Actor a, float[] bbox, float[] correction)
  {
    int corner = (int)correction[2];
    if (corner == -1) return; 

    int sx = (int) bbox[corner],
        sy = (int) bbox[corner+1],
        ex = (int) (bbox[corner] - a.ix),
        ey = (int) (bbox[corner+1] - a.iy),
        minx = (int) bbox[0],  // FIXME: this will be incorrect for rotated actors
        miny = (int) bbox[1];
    PImage mask = a.getSpriteMask();
    if (mask != null) {
      int[] distance = getPermissibleSpriteMaskShift(mask, sx,sy, ex,ey, minx,miny);
      correction[0] -= distance[0];
      correction[1] -= distance[1];
    }
  }


  /**
   * Find the safe distance by which we can move a sprite so that 
   * rather than having its corner touch a boundary, it will look
   * like the sprite's image touches the boundary instead.
   *
   * This uses Bresenham's line algorithm, with a
   * safety conditional to prevent infinite loops.
   */  
  static int[] getPermissibleSpriteMaskShift(PImage m, int x0, int y0, int x1, int y1, int minx, int miny)
  {
    int[] shift = {0,0};
    int sx = x0,
        sy = y0,
        dx = (int) abs(x1-x0),  // distance to travel
        dy = (int) abs(y1-y0),
        ax = (x0<x1) ? 1 : -1,  // x and y stepping values
        ay = (y0<y1) ? 1 : -1,
        imx = 0,                // x and y coordinate on the image mask
        imy = 0,
        err = dx-dy,
        // Conceptually you rely on "while(true)", but no one
        // should ever do that. Safety first: add a cutoff.
        // Verifying over a 65535 pixel line should be enough.
        safety = 0;
    while(safety++ < 0xFFFF) {
      // if we find a pixel in the mask that is not
      // transparent, we have found our safe distance.
      imx = x0-minx;
      imy = y0-miny;
      if(sketch.alpha(m.get(imx,imy)) > 0) {
        shift = new int[]{(x0-sx), (y0-sy)};
        return shift;
      }
      // We must stop when we've reached the end coordinate
      else if(x0==x1 && y0==y1) {
        return shift;
      }
      // continue: move to the next pixel
      int e2 = err<<1;
      if(e2 > -dy) { err -= dy; x0 += ax; }
      if(e2 < dx) { err += dx; y0 += ay; }
    }
    // This code is unreachable, but ONLY in theory.
    // We could still get here if the cutoff is reached.
    return shift;
  }


// =================================================================

  // recycled containers
  private static float[] current_dots = {0,0,0,0,0,0,0,0};
  private static float[] previous_dots = {0,0,0,0,0,0,0,0};
  private static ArrayList<float[]> intersections = new ArrayList<float[]>();
  private static float[] checkLines = {0,0,0,0,0,0,0,0};
  private static float[] ZERO_DIFFERENCE = {0,0,-1};


  /**
   * Line-through-box intersection algorithm.
   *
   * There are a few possibilities, with B() meaning
   * "on blocking side", I() meaning "intersecting"
   * and P() meaning "on pass-through side":
   *
   *               |
   * (1)  []  []  <|    =  B(prev), B(current)
   *               |
   *
   *              |
   * (2)  []    [<|]   =  B(prev), B(current) and I(current) and P(current)
   *              |
   *
   *           |
   * (3)  []  <|  []   =  B(prev), P(current)
   *           |
   *
   *        |
   * (4)  [<|]    []   =  B(prev) and I(prev) and P(prev), P(current)
   *        |
   *
   *
   *       |
   * (5)  <|  []  []   =  P(prev), P(current)
   *       |
   *
   * By computing the dot product for the eight corners of the two bounding
   * boxes, we can determine which of these situations we are in. Only in
   * (2) and (3) should we signal an intersection occuring. While (4) might
   * look like another case in which this should happen, we assume that
   * because the "previous" state is boundary overlapping, it was permitted
   * earlier (for instance, it moved through the boundary in the allowed
   * direction, but then moved back before having fully passed the boundary).
   *
   * DOCUMENTATION FIX: we can actually treat 2 and 3 as the same case, with
   *                    a more reliable result, by always constructing a 
   *                    new intersection-validating parallelogram from the 
   *                    "hot corner" and an adjacent corner in {previous} and
   *                    {current}.
   *
   *
   * @return null if no intersect, otherwise float[3]
   *         indices: [0] = dx, [1] = dy, [2] = bbox (x) index to hit boundary first   
   */
  static float[] getLineRectIntersection(float[] line, float[] current, float[] previous)
  {
    int B_current = 0, B_previous = 0, B_sum = 0;
    float ox=line[0], oy=line[1], tx=line[2], ty=line[3],
          dotx = tx-ox, doty = ty-oy,
          otlen = sqrt(dotx*dotx + doty*doty),
          x, y, dx, dy, len, dotproduct;

    // normalised boundary vector
    dotx /= otlen;
    doty /= otlen;

    // note: we want the dot product with the
    // vector that is perpendicular to the boundary!
    float p = PI/2, cosp = cos(p), sinp = sin(p),
          pdx = dotx*cosp - doty*sinp,
          pdy = dotx*sinp + doty*cosp;

    // how many corners are blocked in [current]?
    for(int i=0; i<8; i+=2) {
      x = current[i];
      y = current[i+1];
      dx = x-ox;
      dy = y-oy;
      len = sqrt(dx*dx+dy*dy);
      dx /= len;
      dy /= len;
      dotproduct = dx*pdx + dy*pdy;
      if (dotproduct < 0) { B_current++; }
      current_dots[i] = dotproduct;
    }

    // how many corners are blocked in [previous]? (copied for speed)
    for(int i=0; i<8; i+=2) {
      x = previous[i];
      y = previous[i+1];
      dx = x-ox;
      dy = y-oy;
      len = sqrt(dx*dx+dy*dy);
      dx /= len;
      dy /= len;
      dotproduct = dx*pdx + dy*pdy;
      if (dotproduct < 0) { B_previous++; }
      previous_dots[i] = dotproduct;
    }

    // cases (1) or (5)?
    B_sum = B_current + B_previous;
    if (B_sum == 0 || B_sum == 8) {
//      println("case " + (B_sum==8? "1" : "5"));
      return null;
    }

    // case (4)?
    if (B_previous < 4 && B_current == 0) {
//      println("case 4");
      return null;
    }

    // Before we continue, find the point in [previous]
    // that is closest to the boundary, since that'll
    // cross the boundary first (based on its dot product
    // value.)
    int corner=-1, curcorner;
    float dotvalue = 999999, curval;
    for(curcorner=0; curcorner<8; curcorner+=2) {
      curval = abs(previous_dots[curcorner]);
      if(curval<dotvalue) {
        corner = curcorner;
        dotvalue = curval; }}

    // Right then. Case (2) or (3)?
    if (B_previous == 4) {
      int currentCase = 2;
      // for (2) and (3) the approach is essentially
      // the same, except that we need different bounding
      // boxes to determine the intersection. For (2) we
      // can use the [current] bounding box, but for (3)
      // we need to construct a new box that is spanned by
      // the two points next to the "hot" corner in both
      // [previous] and [current].
      //
      // FIXME: that said, if we treat (2) as a subset
      //        of (3), things seem to work better.
      checkLines = new float[8];
      arrayCopy(current,0,checkLines,0,8);

      currentCase = 3;

      // two of these edges are guaranteed to not have intersections,
      // since otherwise the intersection would be inside either
      // [previous] or [current], which is case (2) instead.
      checkLines = new float[]{previous[(corner)%8], previous[(corner+1)%8],
                               previous[(corner+2)%8], previous[(corner+3)%8],
                               current[(corner+2)%8],  current[(corner+3)%8],
                               current[(corner)%8],  current[(corner+1)%8]};

      // Now that we have the correct box, perform line/line
      // intersection detection for each edge on the box.
      intersections.clear();
      float x1=checkLines[0], y1=checkLines[1], x2=x1, y2=y1;
      for (int i=0, last=checkLines.length; i<last; i+=2) {
        x2 = checkLines[(i+2)%last];
        y2 = checkLines[(i+3)%last];
        float[] intersection = getLineLineIntersection(ox,oy,tx,ty, x1,y1,x2,y2, false);
        if (intersection!=null) {
          intersections.add(intersection);
          if(intersections.size()==2) { break; }}
        x1 = x2;
        y1 = y2;
      }

      // How many intersections did we find?
      // (We can have zero, one, or two)
      int intersectionCount = intersections.size();

      // get the supposed hit-line
      float px = previous[corner],
            py = previous[corner+1],
            cx = current[corner],
            cy = current[corner+1];

      // if we have two intersections, it's
      // relatively easy to determine by how
      // much we should move back.
      if (intersectionCount == 2)
      {
        float[] i1 = intersections.get(0),
                 i2 = intersections.get(1);
        float[] ideal = getLineLineIntersection(px,py,cx,cy, i1[0],i1[1],i2[0],i2[1], false);
        if (ideal == null) { 
          if(debug) println("error: could not find the case "+currentCase+" ideal point based on corner ["+corner+"]");
          /*
          println("tried to find the intersection between:");
          println("[1] "+px+","+py+","+cx+","+cy+" (blue)");
          println("[2] "+i1[0]+","+i1[1]+","+i2[0]+","+i2[1]+" (green)");
          //debugfunctions_drawBoundingBox(current,sketch);
          //debugfunctions_drawBoundingBox(previous,sketch);
          debugfunctions_drawBoundingBox(checkLines,sketch);
          
          sketch.noLoop();
          sketch.stroke(0,200,255);
          sketch.line(px,py,cx,cy);
          sketch.stroke(0,255,0);
          sketch.line(i1[0],i1[1],i2[0],i2[1]);
          */
          return new float[]{px-cx, py-cy, corner}; 
        }
        return new float[]{ideal[0]-cx, ideal[1]-cy, corner};
      }

      // if there's only one intersection,
      // additional math is required.
      else if (intersectionCount == 1)
      {
        float[] ideal = getLineLineIntersection(px,py,cx,cy, ox,oy,tx,ty, false);
        // this might fail, because it's not necessarily the "hot corner"
        // that ends up touching the boundary if we only have one intersection
        int cv = 0;
        for(cv = 2; cv<8 && ideal==null; cv+=4) {
          px = previous[(corner+cv)%8];
          py = previous[(corner+cv+1)%8];
          cx = current[(corner+cv)%8];
          cy = current[(corner+cv+1)%8];
          ideal = getLineLineIntersection(px,py,cx,cy, ox,oy,tx,ty, false);
        }

        // If ideal is still null, something very curious has happened.
        // Intersections occurred, but none of the corner paths are
        // involved. To the best of my knowledge this is algorithmically
        // impossible. Still, always good to see if I'm wrong:
        if(ideal==null) {
          if(debug) println("error: intersections occurred, but none of the corners were involved!");
          return new float[]{px-cx, py-cy, corner};
        }

        // return the delta and relevant corner
        return new float[]{ideal[0]-cx, ideal[1]-cy, (corner+cv)%8};
      }
    }

    // Uncaught cases get a pass - with a warning.
//    println("unknown case! (B_current: "+B_current+", B_previous: "+B_previous+")");
    return null;
  }


  /**
   * Line-through-line intersection algorithm, using
   * relative rotation and intersection projection.
   *
   * returns float[] representing {x, y, onedge}, where
   *                 onedge=1 means on an edge, onedge=0
   *                 means somewhere inside the bounding box.
   */
  static float[] getLineLineIntersection(float x1, float y1, float x2, float y2, float x3, float y3, float x4, float y4, boolean colinearity)
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
      if (x < min(x1, x2) - epsilon || max(x1, x2) + epsilon < x ||
          y < min(y1, y2) - epsilon || max(y1, y2) + epsilon < y ||
          x < min(x3, x4) - epsilon || max(x3, x4) + epsilon < x ||
          y < min(y3, y4) - epsilon || max(y3, y4) + epsilon < y) {
        // not on either, or both, segments.
        return null;
      }
      return new float[]{x, y};
    }
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
}
/**
 * A static computation class.
 *
 * At the moment this houses the actor/boundary interaction
 * code. This is in its own class, because Processing does
 * not allow you to mix static and non-static code in classes
 * (for the simple reason that all classes are internally
 * compiled into private classes, which cannot be static,
 * so any static class is lifted out of the Sketch code,
 * and it can't do that if you mix regular and static).
 */
static class Computer {

  static boolean debug = false;
  static int _actors = 0, _states = 0, _positionables = 0, _sprites = 0, _arraylists = 0, _hashmaps = 0;
  static void actors() { if(debug) { ts("Actor"); _actors++; }}
  static void states() { if(debug) { ts("State"); _states++; }}
  static void positionables() { if(debug) { ts("Positionable"); _positionables++; }}
  static void sprites() { if(debug) { ts("Sprite"); _sprites++; }}
  static void arraylists(String t) { if(debug) { ts("ArrayList<"+t+">"); _arraylists++; }}
  static void hashmaps(String t, String e) { if(debug) { ts("HashMap<"+t+","+e+">"); _hashmaps++; }}

  // time stamping log function
  static void ts(String s) { 
//    return "["+Date.now()+"] " + s; 
  }
  
/*  
  static void create(String name, String type, int line) {
    if(typeof PJScreates[type] === "undefined") {
      PJScreates[type] = [];
    }
    PJScreates[type].push(ts(name + "[" + line + "]"));
  }
*/
}

/**
 * Decals cannot be interacted with in any way.
 * They are things like the number of points on
 * a hit, or the dust when you bump into something.
 * Decals run through one state, and then expire,
 * so they're basically triggered, temporary graphics.
 */
abstract class Decal extends Sprite {
  boolean remove = false;
  protected int duration;

  /**
   * Decals have spritesheets and position
   */
  Decal(String spritesheet, float x, float y, int duration) {
    super(spritesheet);
    setPosition(x,y);
    this.duration = duration;
    setPath();
  }

  /**
   * subclasses must implement the path on which
   * decals travel before they expire
   */
  abstract void setPath();

  /**
   * Once expired, decals are cleaned up in Level
   */
  void draw(float vx, float vy, float vw, float vh) {
    if(duration-->0) { 
      //super.draw(vx,vy,vw,vh);  // breaks in Pjs
      super.draw(); 
    }
    else { remove = true; }
  }
}
/**
 * Any class that implements this interface
 * is able to draw itself ONLY when its visible
 * regions are inside the indicated viewbox.
 */
interface Drawable {
  void draw(float x, float y, float w, float h);
}
/**
 * This encodes all the boilerplate code
 * necessary for level drawing and input
 * handling.
 */

// global levels container
HashMap<String, Level> levelSet;

// global 'currently active' level
Level activeLevel = null;

// setup sets up the screen size, and level container,
// then calls the "initialize" method, which you must
// implement yourself.
void setup() {
  size(screenWidth, screenHeight);
  noLoop();

  levelSet = new HashMap<String, Level>();
  SpriteMapHandler.init(this);
  SoundManager.init(this);
  CollisionDetection.init(this);
  initialize();
}

// draw loop
void draw() { activeLevel.draw(); }

// event handling
void keyPressed()    { activeLevel.keyPressed(key, keyCode); }
void keyReleased()   { activeLevel.keyReleased(key, keyCode); }
void mouseMoved()    { activeLevel.mouseMoved(mouseX, mouseY); }
void mousePressed()  { activeLevel.mousePressed(mouseX, mouseY, mouseButton); }
void mouseDragged()  { activeLevel.mouseDragged(mouseX, mouseY, mouseButton); }
void mouseReleased() { activeLevel.mouseReleased(mouseX, mouseY, mouseButton); }
void mouseClicked()  { activeLevel.mouseClicked(mouseX, mouseY, mouseButton); }

/**
 * Mute the game
 */
void mute() { SoundManager.mute(true); }

/**
 * Unmute the game
 */
void unmute() { SoundManager.mute(false); }

/**
 * Levels are added to the game through this function.
 */
void addLevel(String name, Level level) {
  levelSet.put(name, level);
  if (activeLevel == null) {
    activeLevel = level;
    loop();
  }
}

/**
 * We switch between levels with this function.
 *
 * Because we might want to move things from the
 * old level to the new level, this function gives
 * you a reference to the old level after switching.
 */
Level setActiveLevel(String name) {
  Level oldLevel = activeLevel;
  activeLevel = levelSet.get(name);
  return oldLevel;
}

/**
 * Levels can be removed to save memory, etc.
 * as long as they are not the active level.
 */
void removeLevel(String name) {
  if (levelSet.get(name) != activeLevel) {
    levelSet.remove(name);
  }
}

/**
 * Get a specific level (for debug purposes)
 */
Level getLevel(String name) {
  return levelSet.get(name);
}

/**
 * clear all levels
 */
void clearLevels() {
  levelSet = new HashMap<String, Level>();
  activeLevel = null;
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
  abstract void setCoordinate(float x, float y);
  abstract void setPaths(ArrayList<ShapePrimitive> segments);
  abstract void recordFramerate(float frameRate);
  abstract void addActor();
  abstract void removeActor();
  abstract void resetActorCount();
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
  // how do we prevent IE9 from not-running-without-debugger-open?
  if(js.console != null) {
    // js.console.log("JavaScript bound to sketch");
  }
}
/**
 * This class defines a generic sprite engine level.
 * A layer may consist of one or more layers, with
 * each layer modeling a 'self-contained' slice.
 * For top-down games, these slices yield pseudo-height,
 * whereas for side-view games they yield pseudo-depth.
 */
abstract class Level {
  boolean finished  = false;
  boolean swappable = false;

  ArrayList<LevelLayer> layers;
  HashMap<String, Integer> layerids;

  // level dimensions
  float width, height;

  // current viewbox
  ViewBox viewbox;

  /**
   * Levels have dimensions!
   */
  Level(float _width, float _height) {
    width = _width;
    height = _height; 
    layers = new ArrayList<LevelLayer>();
    Computer.arraylists("LevelLayer");
    layerids = new HashMap<String, Integer>();
    Computer.hashmaps("String","Integer");
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
  
  // FIXME: THIS IS A TEST FUNCTION. KEEP? REJECT?
  void updatePlayer(Player oldPlayer, Player newPlayer) {
    for(LevelLayer l: layers) {
      l.updatePlayer(oldPlayer, newPlayer);
    }
  }

  /**
   * Change the behaviour when the level finishes
   */
  void finish() { finished = true; }

  /**
   * premature finish
   */
  void end() { finished = true; swappable = true; }
  
  /**
   * Allow this level to be swapped out
   */
  void setSwappable() { swappable = true; } 

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

  // The list of static, non-interacting sprites, building up the background
  void addStaticSpriteBG(Drawable fixed)    { fixed_background.add(fixed);    }
  void removeStaticSpriteBG(Drawable fixed) { fixed_background.remove(fixed); }

  // The list of static, non-interacting sprites, building up the foreground
  void addStaticSpriteFG(Drawable fixed)    { fixed_foreground.add(fixed);    }
  void removeStaticSpriteFG(Drawable fixed) { fixed_foreground.remove(fixed); }

  // The list of decals (pure graphic visuals)
  void addDecal(Decal decal)    { decals.add(decal);   }
  void removeDecal(Decal decal) { decals.remove(decal); }

  // event triggers
  void addTrigger(Trigger trigger)    { triggers.add(trigger);    }
  void removeTrigger(Trigger trigger) { triggers.remove(trigger); }


  // The list of sprites that may only interact with the player(s) (and boundaries)
  void addForPlayerOnly(Pickup pickup) {
    pickups.add(pickup);
    bind(pickup);
    if(javascript!=null) { javascript.addActor(); }}

  void removeForPlayerOnly(Pickup pickup) {
    pickups.remove(pickup);
    if(javascript!=null) { javascript.removeActor(); }}

  // The list of sprites that may only interact with non-players(s) (and boundaries)
  void addForInteractorsOnly(Pickup pickup) {
    npcpickups.add(pickup);
    bind(pickup);
    if(javascript!=null) { javascript.addActor(); }}

  void removeForInteractorsOnly(Pickup pickup) {
    npcpickups.remove(pickup);
    if(javascript!=null) { javascript.removeActor(); }}

  // The list of fully interacting non-player sprites
  void addInteractor(Interactor interactor) {
    interactors.add(interactor);
    bind(interactor);
    if(javascript!=null) { javascript.addActor(); }}

  void removeInteractor(Interactor interactor) {
    interactors.remove(interactor);
    if(javascript!=null) { javascript.removeActor(); }}

  // The list of fully interacting non-player sprites that have associated boundaries
  void addBoundedInteractor(BoundedInteractor bounded_interactor) {
    bounded_interactors.add(bounded_interactor);
    bind(bounded_interactor);
    if(javascript!=null) { javascript.addActor(); }}

  void removeBoundedInteractor(BoundedInteractor bounded_interactor) {
    bounded_interactors.remove(bounded_interactor);
    if(javascript!=null) { javascript.removeActor(); }}

  // The list of player sprites
  void addPlayer(Player player) {
    players.add(player);
    bind(player);
    if(javascript!=null) { javascript.addActor(); }}

  void removePlayer(Player player) {
    players.remove(player);
    if(javascript!=null) { javascript.removeActor(); }}

  void updatePlayer(Player oldPlayer, Player newPlayer) {
    int pos = players.indexOf(oldPlayer);
    if (pos > -1) { 
      players.set(pos, newPlayer);
      bind(newPlayer); }}


  // private actor binding
  void bind(Actor actor) { actor.setLevelLayer(this); }

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
    Computer.arraylists("Boundary");
    fixed_background = new ArrayList<Drawable>();
    Computer.arraylists("Drawable");
    fixed_foreground = new ArrayList<Drawable>();
    Computer.arraylists("Drawable");
    pickups = new ArrayList<Pickup>();
    Computer.arraylists("Pickup");
    npcpickups = new ArrayList<Pickup>();
    Computer.arraylists("Pickup");
    decals = new ArrayList<Decal>();
    Computer.arraylists("Decal");
    interactors = new ArrayList<Interactor>();
    Computer.arraylists("Interactor");
    bounded_interactors = new ArrayList<BoundedInteractor>();
    Computer.arraylists("BoundedInteractor");
    players  = new ArrayList<Player>();
    Computer.arraylists("Player");
    triggers = new ArrayList<Trigger>();
    Computer.arraylists("Trigger");
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
   * map a layer coordinate to "normal"
   */
  float[] mapCoordinateFromScreen(float x, float y) {
    float mx = map(x/xScale,  0,viewbox.w,  viewbox.x,viewbox.x + viewbox.w);
    float my = map(y/yScale,  0,viewbox.h,  viewbox.y,viewbox.y + viewbox.h);    
    return new float[]{mx, my};
  }

  /**
   * map a layer coordinate to "normal"
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
   *
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
    
    pushMatrix();

    // remember to transform the layer coordinates accordingly
    translate(viewbox.x-x, viewbox.y-y);
    scale(xScale, yScale);

// ----  draw fallback color
    if (backgroundColor != -1) {
      background(backgroundColor);
    }

// ---- fixed background sprites
    if(showBackground) {
      for(Drawable s: fixed_background) {
        s.draw(x,y,w,h);
      }
    } else {
      debugfunctions_drawBackground((int)width, (int)height);
    }

// ---- boundaries
    if(showBoundaries) {
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

// ---- pickups
    if(showPickups) {
      for(int i = pickups.size()-1; i>=0; i--) {
        Pickup p = pickups.get(i);
        if(p.remove) {
          pickups.remove(i);
          if(javascript!=null) { javascript.removeActor(); }
          continue; }

        // boundary interference?
        if(p.interacting && !p.onlyplayerinteraction) {
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
    }


// ---- npc pickups
    if(showPickups) {
      for(int i = npcpickups.size()-1; i>=0; i--) {
        Pickup p = npcpickups.get(i);
        if(p.remove) {
          npcpickups.remove(i);
          if(javascript!=null) { javascript.removeActor(); }
          continue; }

        // boundary interference?
        if(p.interacting && !p.onlyplayerinteraction) {
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

// ----  non-player actors
    if(showInteractors) {
      for(int i = interactors.size()-1; i>=0; i--) {
        Interactor a = interactors.get(i);
        if(a.remove) {
          interactors.remove(i);
          if(javascript!=null) { javascript.removeActor(); }
          continue; }

        // boundary interference?
        if(a.interacting && !a.onlyplayerinteraction) {
          for(Boundary b: boundaries) {
              CollisionDetection.interact(b,a); }
          // boundary interference from bounded interactors?
          for(BoundedInteractor o: bounded_interactors) {
            if(o.bounding) {
              for(Boundary b: o.boundaries) {
                  CollisionDetection.interact(b,a); }}}}

        // draw interactor
        a.draw(x,y,w,h);
      }

      // FIXME: code duplication, since it's the same as for regular interactors.
      for(int i = bounded_interactors.size()-1; i>=0; i--) {
        Interactor a = bounded_interactors.get(i);
        if(a.remove) {
          bounded_interactors.remove(i);
          if(javascript!=null) { javascript.removeActor(); }
          continue; }
        // boundary interference?
        if(a.interacting && !a.onlyplayerinteraction) {
          for(Boundary b: boundaries) {
              CollisionDetection.interact(b,a); }}
        // draw interactor
        a.draw(x,y,w,h);
      }
    }
    
// ---- player actors
    if(showActors) {
      for(int i=players.size()-1; i>=0; i--) {
        Player a = players.get(i);

        if(a.remove) {
          players.remove(i);
          if(javascript!=null) { javascript.removeActor(); }
          continue; }

        if(a.interacting) {

          // boundary interference?
          for(Boundary b: boundaries) {
            CollisionDetection.interact(b,a); }

          // boundary interference from bounded interactors?
          for(BoundedInteractor o: bounded_interactors) {
            if(o.bounding) {
              for(Boundary b: o.boundaries) {
                CollisionDetection.interact(b,a); }}}

          // collisions with other sprites?
          if(!a.isDisabled()) {
            for(Actor o: interactors) {
              if(!o.interacting) continue;
              float[] overlap = a.overlap(o);
              if(overlap!=null) {
                a.overlapOccurredWith(o, overlap);
                o.overlapOccurredWith(a, new float[]{-overlap[0], -overlap[1], overlap[2]}); }
              else if(o instanceof Tracker) {
                ((Tracker)o).track(a, x,y,w,h);
              }
            }

            // FIXME: code duplication, since it's the same as for regular interactors.
            for(Actor o: bounded_interactors) {
              if(!o.interacting) continue;
              float[] overlap = a.overlap(o);
              if(overlap!=null) {
                a.overlapOccurredWith(o, overlap);
                o.overlapOccurredWith(a, new float[]{-overlap[0], -overlap[1], overlap[2]}); }
              else if(o instanceof Tracker) {
                ((Tracker)o).track(a, x,y,w,h);
              }
            }
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

// ---- decals
    if(showDecals) {
      for(int i=decals.size()-1; i>=0; i--) {
        Decal d = decals.get(i);
        if(d.remove) { decals.remove(i); continue; }
        d.draw(x,y,w,h);
      }
    }

// ---- fixed foreground sprites
    if(showForeground) {
      for(Drawable s: fixed_foreground) {
        s.draw(x,y,w,h);
      }
    }

// ---- triggerable regions
    if(showTriggers) {
      for(Drawable t: triggers) {
        t.draw(x,y,w,h);
      }
    }

    popMatrix();
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
  Pickup(String pun, String pus, int r, int c, float x, float y, boolean _persistent) {
    super(pun);
    pickup_sprite = pus;
    rows = r;
    columns = c;
    setupStates();
    setPosition(x,y);
    persistent = _persistent;
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
  void align(int halign, int valign) {
    active.sprite.align(halign, valign);
  }

  /**
   * A pickup disappears when touched by a player actor.
   */
  void overlapOccurredWith(Actor other) {
    removeActor();
    other.pickedUp(this);
    pickedUp();
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
  void pickedUp() {}
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
    return new float[]{dx, dy, angle};
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
//    println("attached to b? " + boundaries.size() + " attachments found.");
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
//      println("redirecting impulse {"+_dx+","+_dy+"} over boundary surfaces...");
      float[] redirected = new float[]{_dx, _dy};
      for(int b=boundaries.size()-1; b>=0; b--) {
        Boundary boundary = boundaries.get(b);
        if(!boundary.supports(this)) {
          detachFrom(boundary);
          continue;
        }
        redirected = boundary.redirectForce(redirected[0], redirected[1]);
//        println("redirected to {"+redirected[0]+","+redirected[1]+"}.");
      }
      x += redirected[0];
      y += redirected[1];
    }

    ix *= ixF;
    iy *= iyF;
    
    // Not unimportant: cutoff resolution.
    if(abs(ix) < 0.01) { ix = 0; }
    if(abs(iy) < 0.01) { iy = 0; }
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
  private static boolean muted = true;
  private static Minim minim;
  private static HashMap<Object,AudioPlayer> owners;
  private static HashMap<String,AudioPlayer> audioplayers;
  public static PImage mute_overlay;
  public static PImage unmute_overlay;
  public static PImage volume_overlay;

  static void init(PApplet sketch) { 
    owners = new HashMap<Object,AudioPlayer>();
    audioplayers = new HashMap<String,AudioPlayer>();
    mute_overlay = sketch.loadImage("mute.gif");
    unmute_overlay = sketch.loadImage("unmute.gif");
    volume_overlay = (muted ? unmute_overlay : mute_overlay);
    minim = new Minim(sketch); 
    reset();
  }

  static void reset() {
    owners = new HashMap<Object,AudioPlayer>();
  }

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

  static void play(Object identifier) {
    rewind(identifier);
    AudioPlayer ap = owners.get(identifier);
    if(ap==null) {
      println("ERROR: Error in SoundManager, no AudioPlayer exists for "+identifier.toString());
      return;
    }
    ap.play();
  }

  static void loop(Object identifier) {
    rewind(identifier);
    AudioPlayer ap = owners.get(identifier);
    if(ap==null) {
      println("ERROR: Error in SoundManager, no AudioPlayer exists for "+identifier.toString());
      return;
    }
    ap.loop();
  }

  static void pause(Object identifier) {
    AudioPlayer ap = owners.get(identifier);
    if(ap==null) {
      println("ERROR: Error in SoundManager, no AudioPlayer exists for "+identifier.toString());
      return;
    }
    ap.pause();
  }

  static void rewind(Object identifier) {
    AudioPlayer ap = owners.get(identifier);
    if(ap==null) {
      println("ERROR: Error in SoundManager, no AudioPlayer exists for "+identifier.toString());
      return;
    }
    ap.rewind();
  }

  static void stop(Object identifier) {
    AudioPlayer ap = owners.get(identifier);
    if(ap==null) {
      println("ERROR: Error in SoundManager, no AudioPlayer exists for "+identifier.toString());
      return;
    }
    ap.pause();
    ap.rewind();
  }
  
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

  // frame data
  PImage[] frames;         // sprite frames
  int numFrames=0;         // frames.length cache
  float frameFactor=1;     // determines that frame serving compression/dilation

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
    Computer.sprites();
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
    if(_halign==LEFT)        { halign=width/2; }
    else if(_halign==CENTER) { halign=0; }
    else if(_halign==RIGHT)  { halign=-width/2; }
    ox = halign;

    if(_valign==TOP)         { valign=height/2; }
    else if(_valign==CENTER) { valign=0; }
    else if(_valign==BOTTOM) { valign=-height/2; }
    oy = valign;
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
    ox = -ox;
  }

  /**
   * Flip all frames for this sprite vertically.
   */
  void flipVertical() {
    vflip = !vflip;
    oy = -oy;
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
  void draw() { draw(0,0); }
  void draw(float px, float py) {
    if (visible) {
      PImage img = getFrame();
      float imx = x + px + ox - halfwidth,
             imy = y + py + oy - halfheight;
      image(img, imx, imy);
    }
  }
 
  // pass-through/unused
  boolean drawableFor(float _a, float _b, float _c, float _d) { return true; }
  void draw(float _a, float _b, float _c, float _d) { this.draw(); }
  void drawObject() { println("ERROR: something called Sprite.drawObject instead of Sprite.draw."); }
  
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
    Computer.arraylists("FrameInformation");
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
    Computer.states();
  }

  /**
   * add path points to a state
   */
  void addPathPoint(float x, float y, float sx, float sy, float r, int duration) {
    sprite.addPathPoint(x, y, sx, sy, r, duration); }

  /**
   * add a linear path to the state
   */
  void addPathLine(float x1, float y1, float sx1, float sy1, float r1,
                   float x2, float y2, float sx2, float sy2, float r2,
                   float duration) {
    sprite.addPathLine(x1,y1,sx1,sy1,r1,  x2,y2,sx2,sy2,r2,  duration); }

  /**
   * add a curved path to the state
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
    looping = false;
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
  void draw() { 
    sprite.draw();
    served++; 
    if(served == duration) {
      finished();
    }
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
  
  Trigger(String name, float x, float y, float w, float h) {
    super(x,y,w,h);
    triggername = name;
  }

  boolean drawableFor(float x, float y, float w, float h) {
    return x<=this.x+width && this.x<=x+w && y<=this.y+height && this.y<=y+h;
  }
  
  void drawObject() {
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

///*

final int screenWidth = 512;
final int screenHeight = 432;
void initialize() { 
  addLevel("test", new TestLevel(width,height)); 
}

class TestLevel extends Level {
  TestLevel(float w, float h) {
    super(w,h); 
    addLevelLayer("test", new TestLayer(this,w,h));
  }
  
  void draw() {
    fill(0,1);
    rect(-1,-1,width+2,height+2);
    super.draw();
    stroke(0,255,0,150);
    line(width/2,0,width/2,height);
    line(width/2+16,0,width/2+16,height);
  }
}

class TestLayer extends LevelLayer {
  TestObject t1, t2, t3, t4;
  TestLayer(Level p, float w, float h) {
    super(p,w,h); 
    showBoundaries = true;

    t1 = new TestObject(width/4, height/4);
    t1.setForces(5,0);

    t2 = new TestObject(width/4, 3*height/4);
    t2.setForces(0,-5);

    t3 = new TestObject(3*width/4, 3*height/4);
    t3.setForces(-5,0);

    t4 = new TestObject(3*width/4, height/4);
    t4.setForces(0,5);

//    addPlayer(t1);
    addPlayer(t2);
//    addPlayer(t3);
//    addPlayer(t4);

    addBoundary(new Boundary(width/2+230,height,width/2+200,0));
    addBoundary(new Boundary(width/2-180,0,width/2-150,height));
    
    addBoundary(new Boundary(width,height/2-200,0,height/2-120));
    addBoundary(new Boundary(0,height/2+200,width,height/2+120));

    addBoundary(new Boundary(width/2,height/2,width/2 + 16,height/2));
  }

  void draw() { 
    super.draw();
    
    if (t1.getX() > 0.75*width)      { t1.setForces(-5,0); }
    else if (t1.getX() < 0.25*width) { t1.setForces(5,0); }

    if (t3.getX() > 0.75*width)      { t3.setForces(-5,0); }
    else if (t3.getX() < 0.25*width) { t3.setForces(5,0); }

    if (t2.getY() > 0.75*height)      { t2.setForces(0,-5); }
    else if (t2.getY() < 0.25*height) { t2.setForces(0,5); }

    if (t4.getY() > 0.75*height)      { t4.setForces(0,-5); }
    else if (t4.getY() < 0.25*height) { t4.setForces(0,5); }
  }
  
  void mouseClicked(int mx, int my, int mb) {
    if(mb==RIGHT) { noLoop(); return; }
    boundaries.clear();
    addBoundary(new Boundary(width/2, height/2, mx, my));
  }
}

class TestObject extends Player {
  TestObject(float x, float y) {
    super("test");
    addState(new State("test","docs/tutorial/graphics/mario/small/Standing-mario.gif"));
    setPosition(x,y);
  }
}

//*/
