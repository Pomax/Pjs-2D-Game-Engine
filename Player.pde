/**
 * Players are player-controllable actors.
 */
abstract class Player extends Actor {

  // simple constructor
  Player(String name) { super(name); }

  // full constructor
  Player(String name, float dampening_x, float dampening_y) {
    super(name, dampening_x, dampening_y); }
}
