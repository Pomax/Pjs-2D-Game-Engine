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
