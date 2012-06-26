class MarioBlock extends BoundedInteractor {
  
  int content = 1;
  
  MarioBlock(float x, float y) {
    super("block");
    setPosition(x,y);
    setupStates();
    setupBoundaries();
  }
  
  void setupStates() {
    State hanging = new State("hanging","graphics/assorted/Coin-block.gif",1,4);
    hanging.setAnimationSpeed(0.2);
    addState(hanging);

    State exhausted = new State("exhausted","graphics/assorted/Coin-block-exhausted.gif");
    addState(exhausted);
    
    setCurrentState("hanging");
  }

  void setupBoundaries() {
    float xa = getX()-width/2,
          xb = getX()+width/2,
          ya = getY()-height/2,
          yb = getY()+height/2;
    xa++;
    xb--;
    ya++;
    yb--;
    addBoundary(new Boundary(xa+1,ya, xb-1,ya));
    addBoundary(new Boundary(xb,ya+1, xb,yb-1));
    addBoundary(new Boundary(xb-1,yb, xa+1,yb));
    addBoundary(new Boundary(xa,yb-1, xa,ya+1));
  }
  
  // generate something
  void overlapOccurredWith(Actor other, float[] overlap) {
    if (other instanceof Player) {
      float angle = overlap[2];
      if (content>0 && -1.2*PI > angle && angle > -2*1.2*PI) {
        content--;
        generate();
        if (content == 0) {
          setCurrentState("exhausted");
        }
      }
    }
  }
  
  // generate a "something"
  void generate() {}
}

class CoinBlock extends MarioBlock {
  CoinBlock(float x, float y) {
    super(x,y);
  }
  
  void generate() {
    Coin c = new Coin(getX(), getY()-height/2);
    c.setImpulse(0,-10);
    c.setForces(0, DOWN_FORCE);
    c.setAcceleration(0, ACCELERATION);
    layer.addForPlayerOnly(c);
  }
}

class FlowerBlock extends MarioBlock {
  FlowerBlock(float x, float y) {
    super(x,y);
  }
  
  void generate() {
    FireFlower f = new FireFlower(getX(), getY()-height/2);
    f.setImpulse(0,-10);
    f.setForces(0, DOWN_FORCE);
    f.setAcceleration(0, ACCELERATION);
    layer.addForPlayerOnly(f);
  }
}
