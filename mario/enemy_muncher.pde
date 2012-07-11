/**
 * The muncher plant. To touch it is to lose.
 */
class Muncher extends BoundedMarioEnemy {

  Muncher(float x, float y) {
    super("Muncher");
    setPosition(x,y);
    setupStates();
    addBoundary(new Boundary(x-width/2,y+2-height/2,x+width/2,y+2-height/2), true);
  }

  void setupStates() {
    State munch = new State("munch","graphics/enemies/Muncher.gif", 1, 2);
    munch.setAnimationSpeed(0.20);
    addState(munch);
  }

  void collisionOccured(Boundary boundary, Actor other, float[] correction) {
    if (other instanceof Mario) {
      ((Mario)other).hit();
    }
  }
}
