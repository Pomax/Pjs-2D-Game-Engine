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
  
  void setActor(Actor _actor) { actor = _actor; }

  void reset() { sprite.reset();}

  void finished() {
    if(actor!=null) {
      actor.handleStateFinished(this); }}

  boolean mayChange() { return sprite.mayChange(); }
  void draw() { sprite.draw(); }
}
