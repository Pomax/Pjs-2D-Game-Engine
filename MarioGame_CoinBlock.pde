/***************************************
 *                                     *
 *     INTERACTORS: THE COIN BLOCK     *
 *                                     *
 ***************************************/


/**
 * A coin block generates coins when hit,
 * and will do so eight times (in this code)
 * before turning into an inactive brick.
 */
class CoinBlock extends SpecialBlock {

  /**
   * A coin block holds eight items
   */
  CoinBlock(float x, float y) {
    super("Coin block", x, y);
    content = 8;
  }

  /**
   * generate a coin
   */
  void generate(float[] overlap) {
    Coin coin = new Coin(x, y-30);
    coin.align(CENTER, BOTTOM);
    coin.setImpulse(random(-3, 3), -10);
    coin.setImpulseCoefficients(1, DAMPENING);
    coin.setForces(0, DOWN_FORCE);
    coin.setAcceleration(0, ACCELERATION);
    coin.persistent = false;
    layer.addForPlayerOnly(coin);
  }
}