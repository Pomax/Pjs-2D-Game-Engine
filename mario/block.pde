class MarioBlock extends BoundedInteractor {
  
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
  }

  void setupBoundaries() {
    float xa = getX()-width/2,
          xb = getX()+width/2,
          ya = getY()-height/2,
          yb = getY()+height/2;
    addBoundary(new Boundary(xa+1,ya, xb-1,ya));
    addBoundary(new Boundary(xb,ya+1, xb,yb-1));
    addBoundary(new Boundary(xb-1,yb, xa+1,yb));
    addBoundary(new Boundary(xa,yb-1, xa,ya+1));
  }
}

class CoinBlock extends MarioBlock {
  CoinBlock(float x, float y) {
    super(x,y);
  }
}
