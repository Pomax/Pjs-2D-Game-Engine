/**
 * The muncher plant. To touch it is to lose.
 */
class Muncher extends Interactor {

  Muncher(float x, float y) {
    super("Muncher");
    setPosition(x,y);
    setupStates();
  }

  void setupStates() {
    State munch = new State("munch","graphics/enemies/Muncher.gif", 1, 2);
    munch.setAnimationSpeed(0.20);
    addState(munch);
  }

  void overlapOccurredWith(Actor other, float[] overlap) {
    super.overlapOccurredWith(other, overlap);
    if (other instanceof Mario) {
      ((Mario)other).die();
    }
  }
}
