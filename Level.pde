/**
 * This is a test class for implementing levels.
 * note that while this tests a sidescroller
 * (effectively), it should be equally suited to
 * doing top-down view things (say, zelda?) or
 * isometric levels (head over heels?)
 */
class Level {
  // the list of "standable" regions
  ArrayList<Boundary> boundaries = new ArrayList<Boundary>();

  // TODO: add and retrieve boundaries based on grid coordinates

  // non-player static sprites
  ArrayList<Positionable> npss = new ArrayList<Positionable>();

  // non-player active sprites
  ArrayList<Actor> npas = new ArrayList<Actor>();

  // player sprite(s)
  ArrayList<Actor> actors = new ArrayList<Actor>();
  
  /**
   * draw
   */
  void draw() {
    fill(0);
    for(Positionable s: npss) { s.draw(); }
    for(Boundary b: boundaries) { b.draw(); }
    for(Actor a: npas) {
      for(Boundary b: boundaries) { 
        if(a.boundary==null) {
          interact(b,a); }}
      a.draw();
    }
    for(Actor a: actors) {
      for(Boundary b: boundaries) {
        if(a.boundary==null) {
          interact(b,a); }}
      a.draw();
    }   
  }
  
  /**
   * Perform actor/boundary collision detection
   */
  void interact(Boundary b, Actor a) {
    float[] intersection = b.blocks(a);
    if(intersection!=null) {
      a.stop(intersection[0], intersection[1]);
      a.attachTo(b);
    }
  }
  
  // passthrough event
  void keyPressed(char key, int keyCode) {
    for(Actor a: actors) {
      a.keyPressed(key,keyCode); }}

  // passthrough event
  void keyReleased(char key, int keyCode) {
    for(Actor a: actors) {
      a.keyReleased(key,keyCode); }}

  void mouseMoved(int mx, int my) {}
  void mousePressed(int mx, int my) {}
  void mouseDragged(int mx, int my) {}
  void mouseReleased(int mx, int my) {}
  void mouseClicked(int mx, int my) {}
}
