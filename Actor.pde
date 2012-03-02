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

  // bypass regular interaction for ... frames
  int disabledCounter = 0;

  // should we be removed?
  boolean remove = false;
  
  // is this actor persistent with respect to viewbox draws?
  boolean persistent = true;

  // The active state for this actor (with associated sprite)
  State active;

  // all states for this actor
  HashMap<String, State> states = new HashMap<String, State>();

  // actor name
  String name = "";

  // simple constructor
  Actor(String _name) {
    name = _name;
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
   * Set the actor's current state by name.
   */
  void setCurrentState(String name) {
    State tmp = states.get(name);
    if (tmp!=active) {
      tmp.reset();
      boolean hflip = active.sprite.hflip,
               vflip = active.sprite.vflip;
      active = tmp;
      if(hflip) active.sprite.flipHorizontal();
      if(vflip) active.sprite.flipVertical();
      width = active.sprite.width;
      height = active.sprite.height;
      halign = active.sprite.halign;
      valign = active.sprite.valign;
    }
  }

  /**
   * update the actor dimensions based
   * on the currently active state.
   */
  void updatePositioningInformation() {
    width = active.sprite.width;
    height = active.sprite.height;
    halign = active.sprite.halign;
    valign = active.sprite.valign;
  }

  /**
   * get the midpoint
   */
  float getMidX() { return super.getMidX() - (active==null ? 0 : active.sprite.ox); }

  /**
   * get the midpoint
   */
  float getMidY() { return super.getMidY() - (active==null ? 0 : active.sprite.oy); }

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
  void overlapOccuredWith(Actor other, float[] direction) {
    colliding = true;
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
      if(debug) {
        fill(255,0,0);
        ellipse(0,0,5,5);
        noFill();
        stroke(255,0,0);
        rect(-width/2-halign,-height/2-valign,width,height);
      }
    }
    else {
      pushStyle();
      strokeWeight(7);
      stroke(200,0,100);
      point(0,0); popStyle();
    }
/*
    if(active!=null && colliding) {
      pushStyle();
      noStroke();
      fill(255,0,0,150);
      rect(-width/2+active.sprite.ox,-height/2-active.sprite.oy,width,height);
      popStyle();
    }
    colliding = false;
*/
  }

// ====== KEY HANDLING ======

  protected final boolean[] locked = new boolean[256];
  protected final boolean[] keyDown = new boolean[256];
  protected final int UP=38, LEFT=37, DOWN=40, RIGHT=39, // cursor keys
                      BUTTON_A=90, BUTTON_B=88;      // jump + shoot

  protected final int[] keyCodes = {UP, LEFT, DOWN, RIGHT, BUTTON_A, BUTTON_B};

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
    keyDown[keyCode] = false;
  }

  // handle key presses
  void keyPressed(char key, int keyCode) {
    for(int i: keyCodes) {
      setIfTrue(keyCode, i); }}

  // handle key releases
  void keyReleased(char key, int keyCode) {
    for(int i: keyCodes) {
      unsetIfTrue(keyCode, i); }}

// ====== ABSTRACT METHODS ======

  // token implementation
  abstract void handleInput();

  // token implementation
  abstract void handleStateFinished(State which);

  // token implementation
  abstract void pickedUp(Pickup pickup);
}
