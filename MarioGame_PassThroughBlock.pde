/***************************************
 *                                     *
 * INTERACTORS: THE PASS-THROUGH BLOCK *
 *                                     *
 ***************************************/


/**
 * Much like the special blocks, the pass-through
 * block is interactable, and so it counts as an
 * interactor, rather than as a static sprite.
 */
class PassThroughBlock extends BoundedInteractor {

  /**
   * blocks just hang somewhere.
   */
  PassThroughBlock(float x, float y) {
    super("Pass-through block");
    setPosition(x, y);
    setForces(0, 0);
    setAcceleration(0, 0);
    setupStates();
    // make the top of this block a platform
    addBoundary(new Boundary(x-width/2, y-height/2-1, x+width/2, y-height/2-1));
  }

  /**
   * A pass-through block has a static sprite,
   * unless it has been hit. Then it has a rotating
   * sprite that signals it can be jumped through.
   */
  void setupStates() {
    State hanging = new State("hanging", "graphics/assorted/Block.gif");
    hanging.sprite.setAnimationSpeed(0.25);
    addState(hanging);

    State passthrough = new State("passthrough", "graphics/assorted/Passthrough-block.gif", 1, 4);
    passthrough.sprite.setAnimationSpeed(0.25);
    passthrough.sprite.setLooping(false);
    // the passthrough state lasts for 96 frames
    passthrough.sprite.addPathPoint(0, 0, 1, 1, 0, 96);
    addState(passthrough);

    setCurrentState("hanging");
  }

  /**
   * Test for sprite overlap, as well as boundary overlap
   */
  float[] overlap(Positionable other) {
    float[] overlap = super.overlap(other);
    if (overlap==null) {
      for (Boundary boundary: boundaries) {
        overlap = boundary.overlap(other);
        if (overlap!=null) return overlap;
      }
    }
    return null;
  }

  /**
   * Are we triggered? If so, and we're not in pass-through
   * state, we switch to pass-through state and stop being
   * interactive until the state finishes.
   */
  void overlapOccurredWith(Actor other, float[] overlap) {
    // stop actor movement if we're not in passthrough state
    if (active.name!="passthrough") {

      // Did we get spin-jumped on?
      if (other instanceof Mario && ((Mario)other).active.name=="spinning") {
        removeActor();
        return;
      }

      // We did not. See if we should become pass-through.
      other.rewindPartial();
      other.ix=0;
      other.iy=0;
      float minv = 3*PI/2 - radians(45);
      float maxv = 3*PI/2 + radians(45);
      if (minv <=overlap[2] && overlap[2]<=maxv) {
        setCurrentState("passthrough");
        disableBoundaries();
      }
    }
  }

  /**
   * When the pass-through state is done, go back
   * to being a normal block. Until the next time
   * someone decides to hit us from below.
   */
  void handleStateFinished(State which) {
    if (which.name=="passthrough") {
      setCurrentState("hanging");
      enableBoundaries();
    }
  }
}