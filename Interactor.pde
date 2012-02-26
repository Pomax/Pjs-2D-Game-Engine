abstract class Interactor extends Actor {

  // simple constructor
  Interactor(String name) { super(name); }

  // full constructor
  Interactor(String name, float dampening_x, float dampening_y) {
    super(name, dampening_x, dampening_y); }

  // Interactors don't get pickups
  final void pickedUp(Pickup pickup){}

}
