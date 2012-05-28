/**
 * A sprite state is mostly a thin wrapper
 */
class State {
  String name;
  Sprite sprite;
  Actor actor;

  // this point is considered the "center point" when
  // swapping between states. If a state has an anchor
  // at (3,3), mapping to world coordinate (240,388)
  // and it swaps for a state that has (10,10) as anchor,
  // the associated actor is moved (-7,-7) to effect
  // the anchor being in the same place before and after.
  float ax, ay;

  // shortcut constructor
  State(String name, String spritesheet) {
    this(name, spritesheet, 1, 1);
  }

  // bigger shortcut constructor
  State(String _name, String spritesheet, int rows, int cols) {
    name = _name;
    sprite = new Sprite(spritesheet, rows, cols);
    sprite.setState(this);
    Computer.states();
  }

  // bind this state to an actor
  void setActor(Actor _actor) {
    actor = _actor;
    actor.width = sprite.width;
    actor.height = sprite.height;
  }

  // when the sprite is moved by its path,
  // let the actor know of its updated position.
  void setActorOffsets(float x, float y) {
    actor.setTranslation(x, y);
  }

  void setActorDimensions(float w, float h, float xa, float ya) {
    actor.width = w;
    actor.height = h;
    actor.halign = xa;
    actor.valign = ya;
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
