final int screenWidth = 512;
final int screenHeight = 512;


void initialize() {
  SoundManager.mute(false);
  frameRate(10);
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
    addBoundary(new Boundary(0,height/2,12*18-2,height/2));
    for(int i=12*18; i<width; i+=18) {
      addBoundary(new Boundary(i,height/2, i+16, height/2));
    }
    
    TestPlayer tp = new TestPlayer(width/2, 0);
    tp.setForces(0,3);
    tp.setAcceleration(0,1.5);
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
    if(isKeyDown('W')) { addImpulse(0,-1); }
    if(isKeyDown('A')) { addImpulse(-1,0); }
    if(isKeyDown('S')) { addImpulse(0, 1); }
    if(isKeyDown('D')) { addImpulse( 1,0); }
  }
}
