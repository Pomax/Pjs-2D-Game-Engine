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

  // non-player static sprites
  ArrayList<Sprite> npss = new ArrayList<Sprite>();

  // non-player active sprites
  ArrayList<Actor> npas = new ArrayList<Actor>();

  // player sprite(s)
  ArrayList<Actor> actors = new ArrayList<Actor>();
  
  // draw   
  void draw() {
    fill(0);
    for(Sprite s: npss) { s.draw(); }
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
  
  // see if we can pass through platforms
  void interact(Boundary b, Actor a) {
    float[] intersection = b.blocks(a);
    if(intersection!=null) {
      a.stop(intersection[0], intersection[1]);
      a.attachTo(b);
    }
  }

  void keyPressed(char key, int keyCode) {
    for(Actor a: actors) {
      a.keyPressed(key,keyCode); }}

  void keyReleased(char key, int keyCode) {
    for(Actor a: actors) {
      a.keyReleased(key,keyCode); }}
}
