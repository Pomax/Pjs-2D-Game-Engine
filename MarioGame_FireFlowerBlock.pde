/***************************************
 *                                     *
 * INTERACTORS: THE FIRE FLOWER BLOCK  *
 *                                     *
 ***************************************/


/**
 * A fire flower block generates a flower when hit
 */
class FireFlowerBlock extends SpecialBlock {

  /**
   * Passthrough constructor
   */
  FireFlowerBlock(float x, float y) {
    super("Fire flower block", x, y);
  }

  /**
   * Generate a mushroom
   */
  void generate(float[] overlap) {
    Flower flower = new Flower(x, y);
    flower.setImpulse(0, -8);
    flower.setForces(0, 2*DOWN_FORCE);
    flower.persistent = false;
    layer.addForPlayerOnly(flower);
  }
}