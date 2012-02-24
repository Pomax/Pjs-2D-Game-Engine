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

  // The active state for this actor (with associated sprite)
  State active;

  // all states for this actor
  HashMap<String, State> states = new HashMap<String, State>();
  
  // simple constructor
  Actor() { setPosition(0,0); }

  // full constructor
  Actor(float dampening_x, float dampening_y) {
    super();
    setImpulseCoefficients(dampening_x, dampening_y);
  }

  /**
   * Add a state to this actor's repetoire.
   */
  void addState(State state) { 
    state.setActor(this);
    states.put(state.name, state); 
    active = state;
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
      active = tmp;
    }
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
   * Draw preprocessing happens here.
   */
  void draw() {
    handleInput();
    super.draw();
  }

  /**
   * Draw this actor.
   */
  void drawObject() {
    if(active!=null) { active.draw(); }
    else { pushStyle(); strokeWeight(7); stroke(200,0,100); point(0,0); popStyle(); }
  }

// ====== KEY HANDLING ======

  protected final boolean[] locked = new boolean[256];
  protected final boolean[] keyDown = new boolean[256];
  protected final int UP=38, LEFT=37, DOWN=40, RIGHT=39;           // cursor keys
  protected final char cUP='w', cLEFT='a', cDOWN='s', cRIGHT='d',  // wasd controls
                       BUTTON_A='z', BUTTON_B='x';                 // controll buttons

  protected final int[] keyCodes = {UP, LEFT, DOWN, RIGHT};
  protected final int[] keys = {cUP, cLEFT, cDOWN, cRIGHT, BUTTON_A, BUTTON_B};

  // if pressed, and part of our known keyset, mark key as "down"
  private void setIfTrue(int mark, int target) {
    if(!locked[target]) {
      if(mark==target) {
        keyDown[target] = true; }}}

  // if released, and part of our known keyset, mark key as "released"
  private void unsetIfTrue(int mark, int target) {
    if(mark==target) {
      locked[target]=false;
      keyDown[target] = false; }}

  // lock a key so that it cannot be triggered repeatedly
  protected void lock(int keyCode) {
    locked[keyCode] = true; }

  // handle key presses
  void keyPressed(char key, int keyCode) {
    for(int i: keys) { setIfTrue(key, i); }
    for(int i: keyCodes) { setIfTrue(keyCode, i); }}

  // handle key releases
  void keyReleased(char key, int keyCode) {
    for(int i: keys) { unsetIfTrue(key, i); }
    for(int i: keyCodes) { unsetIfTrue(keyCode, i); }}

// ====== ABSTRACT METHODS ======

  // token implementation
  abstract void handleInput();

  // token implementation  
  abstract void handleStateFinished(State which);
}
