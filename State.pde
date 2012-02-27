/**
 * A sprite state is mostly a thin wrapper
 */
class State {
  String name;
  String spritesheet;
  Sprite sprite;
  Actor actor;

  // shortcut constructor
  State(String name, String spritesheet) {
    this(name, spritesheet, 1, 1);
  }

  // full constructor
  State(String _name, String _spritesheet, int rows, int cols) {
    name = _name;
    spritesheet = _spritesheet;
    sprite = new Sprite(spritesheet, rows, cols);
    sprite.setState(this);
  }

  // bind this state to an actor
  void setActor(Actor _actor) {
    actor = _actor; 
    actor.width = sprite.width;
    actor.height = sprite.height;
  }

  // reset a sprite (used when swapping states)
  void reset() { sprite.reset();}

  // signal to the actor that the sprite is done running its path
  void finished() {
    if(actor!=null) {
      actor.handleStateFinished(this); }}

  // if the sprite has a non-looping path: is it done running that path?
  boolean mayChange() { return sprite.mayChange(); }

  // drawing the state means draw the sprite
  void draw() { sprite.draw(); }
}
