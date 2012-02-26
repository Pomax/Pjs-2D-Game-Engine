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
   * Pickups are 
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
  }

  // unused
  void handleInput() {}

  // unused
  void handleStateFinished(State which) {}

  // unused
  void pickedUp(Pickup pickup) {}
}

