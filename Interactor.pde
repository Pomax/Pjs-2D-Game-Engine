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

  // Interactors don't get pickups
  final void pickedUp(Pickup pickup){}
}
