/**
 * A sprite state is mostly a thin wrapper
 */
class State {
  String name;
  Sprite sprite;
  Actor actor;

  State(String _name, String spritesheet, int rows, int cols) {
    name = _name;
    sprite = new Sprite(spritesheet, rows, cols);
    sprite.setState(this);
  }
  
  void setActor(Actor _actor) { actor = _actor; }

  void reset() { sprite.reset();}

  void stop() {
    sprite.stop();
    if(actor!=null) {
      actor.handleStateFinished(this); }}

  boolean mayChange() { return sprite.mayChange(); }
  void draw() { sprite.draw(); }
}
