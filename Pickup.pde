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

