/***************************************
 *                                     *
 *          SPECIAL BOUNDARIES         *
 *                                     *
 ***************************************/


/**
 * Removable boundary for pipes
 */
class PipeBoundary extends Boundary {
  // wrapper constructor
  PipeBoundary(float x1, float y1, float x2, float y2) {
    super(x1, y1, x2, y2);
    SoundManager.load(this, "audio/Pipe.mp3");
  }
  // used to effect "teleporting" incombination with the tube trigger
  void teleport() {
    disable();
    SoundManager.play(this);
  }
}