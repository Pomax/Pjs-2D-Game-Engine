final int screenWidth = 512;
final int screenHeight = 512;


void initialize() {
  SoundManager.mute(false);
//  frameRate(10);
  reset();
}

void reset() {
  clearScreens();
  addScreen("Main Level", new MainLevel(width, height));  
}

class MainLevel extends Level {
  MainLevel(float levelWidth, float levelHeight) {
    super(levelWidth, levelHeight);
    addLevelLayer("Main Layer", new MainLayer(this));
  }
}

class MainLayer extends LevelLayer {
  MainLayer(Level owner) {
    super(owner);
    setBackgroundColor(color(0,130,255));
    
    showBoundaries = true;
//    addBoundary(new Boundary(0,height/2,12*18-2,height/2));
    int step = 1, gap = 20, full = step + gap;
    for(int i=int(width/4); i<width; i+=full) {
      addBoundary(new Boundary(i,height/2, i+step, height/2));
    }

    addBoundary(new Boundary(0,height-20,width,height-20));

    
    TestPlayer tp = new TestPlayer(width/2, 0);
    tp.setForces(0,1);
    tp.setAcceleration(0,1.3);
    tp.setImpulseCoefficients(0.75,0.75);
    addPlayer(tp);
  }
}

class TestPlayer extends Player {
  TestPlayer(float x, float y) {
    super("player");
    handleKey('W');
    handleKey('A');
    handleKey('S');
    handleKey('D');
    addState(new State("idle", "testplayer.gif"));
    setPosition(x,y);
  }
  
  void handleInput() {
    if(isKeyDown('W')) { addImpulse(0,-2); }
    if(isKeyDown('A')) { addImpulse(-2,0); }
    if(isKeyDown('S')) { addImpulse(0, 2); }
    if(isKeyDown('D')) { addImpulse( 2,0); }
  }
}
