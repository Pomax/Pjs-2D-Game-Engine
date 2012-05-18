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
    bounds[0] += x+ox; bounds[1] += y+oy;  // top left
    bounds[2] += x+ox; bounds[3] += y+oy;  // top right
    bounds[4] += x+ox; bounds[5] += y+oy;  // bottom right
    bounds[6] += x+ox; bounds[7] += y+oy;  // bottom left
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
   * This boundary blocked our path.
   */
  void gotBlocked(Boundary b, float[] intersection) {
    // subclasses can implement, but don't have to
  }

  /**
   * collisions may force us to stop this
   * actor's movement.
   */
  void stop(float _x, float _y) {
    x = _x;
    y = _y;
    ix = 0;
    iy = 0;
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
    handleInput();
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
        noFill();
        stroke(255,0,0);
        float[] bounds = getBoundingBox();
        beginShape();
        vertex(bounds[0]-x-ox,bounds[1]-y-oy);
        vertex(bounds[2]-x-ox,bounds[3]-y-oy);
        vertex(bounds[4]-x-ox,bounds[5]-y-oy);
        vertex(bounds[6]-x-ox,bounds[7]-y-oy);
        endShape(CLOSE); 
        fill(255,0,0);
        ellipse(0,0,5,5);
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
  abstract void handleInput();

  // token implementation
  abstract void handleStateFinished(State which);

  // token implementation
  abstract void pickedUp(Pickup pickup);
}
