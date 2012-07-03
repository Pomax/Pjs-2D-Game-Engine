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
    xb = (getX() + width/2), 
    ya = (getY() - height/2), 
    yb = (getY() + height/2);
    addBoundary(new Boundary(xa+1, ya, xb-1, ya));
    addBoundary(new Boundary(xb, ya+1, xb, yb-1));
    addBoundary(new Boundary(xb-1, yb, xa+1, yb));
    addBoundary(new Boundary(xa, yb-1, xa, ya+1));
  }

  // generate something
  void overlapOccurredWith(Actor other, float[] overlap) {
    // do nothing if we can't generate anything (anymore)
    if (content == 0) return;
    // otherwise, see if we need to generate something.
    if (other instanceof Player) {
      float angle = overlap[2];
      if (content>0 && -1.25*PI > angle && angle > -1.75*PI) {
        // generate a "something"
        generate(angle);
        // we can also generate 1 fewer things now
        content--;
        if (content == 0) {
          // nothing left to generate: change state
          setCurrentState("exhausted");
        }
      }
    }
  }

  // generate a "something". subclasses must implement this
  abstract void generate(float angle);
}


/**
 * Coin block
 */
class CoinBlock extends MarioBlock {
  CoinBlock(float x, float y) {
    super("Coin block", x, y);
  }

  void generate(float angle) {
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
  void generate(float angle) {}
}



/**
 * Mushroom block
 */
class MushroomBlock extends MarioBlock {
  float mushroom_speed = 0.7;
  
  MushroomBlock(float x, float y) {
    super("Mushroom block", x, y);
  }

  void generate(float angle) {
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

  void generate(float angle) {
    FireFlower f = new FireFlower(getX(), getY()-height/2);
    f.setImpulse(0, -10);
    f.setForces(0, DOWN_FORCE);
    f.setAcceleration(0, ACCELERATION);
    layer.addForPlayerOnly(f);
  }
}

