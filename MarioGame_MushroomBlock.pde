/***************************************
 *                                     *
 *   INTERACTORS: THE MUSHROOM BLOCK   *
 *                                     *
 ***************************************/


/**
 * A mushroom block generates powerup mushrooms when hit
 */
class MushroomBlock extends SpecialBlock {

  /**
   * Passthrough constructor
   */
  MushroomBlock(float x, float y) {
    super("Mushroom block", x, y);
  }

  /**
   * Generate a mushroom
   */
  void generate(float[] overlap) {
    Mushroom mushroom = new Mushroom(x, y-16);
    mushroom.setForces((overlap[0]<0 ? 1 : -1) * 2, DOWN_FORCE);
    mushroom.persistent = false;
    layer.addForPlayerOnly(mushroom);
  }
}