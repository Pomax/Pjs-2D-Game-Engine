/**
 * blocks are interactors (NPCs) that are
 * fixed in place by default, and generate
 * a "something" when hit from the right
 * direction.
 */
abstract class MarioBlock extends BoundedInteractor {

  // how many "somethings" can be generated?
  int content = 1;

  MarioBlock(String name, float x, float y) {
    super(name);
    setPosition(x, y);
    setupStates();
    setupBoundaries();
  }

  void setupStates() {
    State hanging = new State("hanging", "graphics/assorted/Coin-block.gif", 1, 4);
    hanging.setAnimationSpeed(0.2);
    addState(hanging);

    State exhausted = new State("exhausted", "graphics/assorted/Coin-block-exhausted.gif");
    addState(exhausted);

    setCurrentState("hanging");
  }

  void setupBoundaries() {
    float xa = (getX() - width/2),
          xb = (getX() + width/2)-1,
          ya = (getY() - height/2),
          yb = (getY() + height/2)-1;
    
    addBoundary(new Boundary(xa, yb-1, xa, ya+1));
    addBoundary(new Boundary(xa, ya, xb, ya));
    addBoundary(new Boundary(xb, ya+1, xb, yb-1));
    // the bottom boundary is special, because we want
    // to know whether things collide with it.
    addBoundary(new Boundary(xb, yb, xa, yb), true);
  }

  // generate something
  void collisionOccured(Boundary boundary, Actor other, float[] intersectionInformation) {
    // do nothing if we can't generate anything (anymore)
    if (content == 0) return;
    // otherwise, see if we need to generate something.
    if (other instanceof Player) {
      // generate a "something"
      generate(intersectionInformation);
      // we can also generate 1 fewer things now
      content--;
      if (content == 0) {
        // nothing left to generate: change state
        setCurrentState("exhausted");
      }
    }
  }

  // generate a "something". subclasses must implement this
  abstract void generate(float[] intersectionInformation);
}


/**
 * Coin block
 */
class CoinBlock extends MarioBlock {
  CoinBlock(float x, float y) {
    super("Coin block", x, y);
  }

  void generate(float[] intersectionInformation) {
    Coin c = new Coin(getX(), getY()-height/2);
    c.setImpulse(0, -10);
    c.setForces(0, DOWN_FORCE);
    c.setAcceleration(0, ACCELERATION);
    layer.addForPlayerOnly(c);
  }
}

/**
 * Sky block
 */
class SkyBlock extends MarioBlock {
  SkyBlock(float x, float y) {
    super("Sky block", x, y);
    addState(new State("hanging", "graphics/assorted/Sky-block.gif"));
    addState(new State("exhausted", "graphics/assorted/Sky-block.gif"));
  }
  void generate(float[] intersectionInformation) {}
}



/**
 * Mushroom block
 */
class MushroomBlock extends MarioBlock {
  float mushroom_speed = 0.7;
  
  MushroomBlock(float x, float y) {
    super("Mushroom block", x, y);
  }

  void generate(float[] intersectionInformation) {
    float angle = atan2(intersectionInformation[1],intersectionInformation[0]);
    Mushroom m = new Mushroom(getX(), getY()-height/2);
    m.setImpulse((angle<-1.5*PI ? -1:1) * mushroom_speed, -10);
    m.setImpulseCoefficients(0.75,0.75);
    m.setForces((angle<-1.5*PI ? 1:-1) * mushroom_speed, DOWN_FORCE);
    m.setAcceleration(0,0);
    layer.addForPlayerOnly(m);
  }
}


/**
 * Fireflow powerup block
 */
class FlowerBlock extends MarioBlock {
  FlowerBlock(float x, float y) { 
    super("Fireflower block", x, y);
  }

  void generate(float[] intersectionInformation) {
    FireFlower f = new FireFlower(getX(), getY()-height/2);
    f.setImpulse(0, -10);
    f.setForces(0, DOWN_FORCE);
    f.setAcceleration(0, ACCELERATION);
    layer.addForPlayerOnly(f);
  }
}

