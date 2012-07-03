/**
 * The muncher plant. To touch it is to lose.
 */
class Muncher extends BoundedInteractor {

  Muncher(float x, float y) {
    super("Muncher");
    setPosition(x,y);
    setupStates();
    addBoundary(new Boundary(x-width/2,y+2-height/2,x+width/2,y+2-height/2));
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
