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
  boolean debug = false;
  
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
