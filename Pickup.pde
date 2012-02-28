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
  Pickup(String pun, String pus, int r, int c, float x, float y) {
    super(pun);
    pickup_sprite = pus;
    rows = r;
    columns = c;
    setupStates();
    setPosition(x,y);
  }

  /**
   * Pickup sprite animation.
   */
  void setupStates() {
    State pickup = new State(name, pickup_sprite, rows, columns);
    pickup.sprite.setAnimationSpeed(0.25);
    addState(pickup);
  }

  /**
   * A pickup disappears when touched by a player actor.
   */
  void overlapOccuredWith(Actor other) {
    removeActor();
    other.pickedUp(this);
    pickedUp();
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

