/***************************************
 *                                     *
 *   INTERACTORS: THE SPECIAL BLOCK    *
 *                                     *
 ***************************************/


/**
 * Perhaps unexpected, blocks can also be
 * interactors. They get bonked just like
 * enemies, and they do things based on the
 * interaction.
 */
abstract class SpecialBlock extends BoundedInteractor {

  // how many things do we hold?
  int content = 1;

  /**
   * Special blocks just hang somewhere.
   */
  SpecialBlock(String name, float x, float y) {
    super(name);
    setPosition(x, y);
    setForces(0, 0);
    setAcceleration(0, 0);
    setupStates();
    // make the top of this block a platform
    addBoundary(new Boundary(x-width/2, y-height/2, x+width/2, y-height/2));
  }

  /**
   * A special block has an animated sprite,
   * until it's exhausted and turns into a brick.
   */
  void setupStates() {
    // when just hanging in the level
    State hanging = new State("hanging", "graphics/assorted/Coin-block.gif", 1, 4);
    hanging.sprite.setAnimationSpeed(0.25);
    addState(hanging);

    // when Mario jumps into us from below
    State boing = new State("boing", "graphics/assorted/Coin-block.gif", 1, 4);
    boing.sprite.setAnimationSpeed(0.25);
    boing.sprite.setNoRotation(true);
    boing.sprite.setLooping(false);
    boing.sprite.addPathLine(0, 0, 1, 1, 0, 
    0, -8, 1, 1, 0, 
    1);
    boing.sprite.addPathLine(0, -12, 1, 1, 0, 
    0, 0, 1, 1, 0, 
    2);
    SoundManager.load(boing, "audio/Coin.mp3");
    addState(boing);

    // when we've run out of things to spit out
    State exhausted = new State("exhausted", "graphics/assorted/Coin-block-exhausted.gif", 1, 1);
    addState(exhausted);

    setCurrentState("hanging");
  }

  /**
   * are we triggered?
   */
  void overlapOccurredWith(Actor other, float[] overlap) {
    if (active.name=="hanging" || active.name=="exhausted") {
      // First order of business: stop actor movement
      other.rewindPartial();
      other.ix=0;
      other.iy=0;

      // If we're exhausted, shortcircuit
      if (content==0 || active.name=="boing") return;

      // If we're not, see if we got hit
      // from the right direction, and pop
      // some coins out the top if we are.
      float minv = 3*PI/2 - radians(45);
      float maxv = 3*PI/2 + radians(45);
      if (minv <=overlap[2] && overlap[2]<=maxv) {
        content--;
        setCurrentState("boing");
        SoundManager.play(active);
        generate(overlap);
      }
    }
  }

  /**
   * If, at the end of spawning a coin, we're
   * out of coins, turn into a brick.
   */
  void handleStateFinished(State which) {
    if (which.name=="boing") {
      if (content>0) { 
        setCurrentState("hanging");
      }
      else { 
        setCurrentState("exhausted");
      }
    }
  }

  /**
   * Since subclasses can generate different
   * things, we leave it up to them to do
   * figure out which code to call.
   */
  abstract void generate(float[] overlap);
}