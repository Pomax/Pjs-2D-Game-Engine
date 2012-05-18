/***************************************
 *                                     *
 *      LET'S GET OUR NINTENDO ON!     *
 *                                     *
 ***************************************/

// This value determines how much we "slide" when we walk
float DAMPENING = 0.75;

// This value determines how much 'gravity' we experience
float DOWN_FORCE = 0.7;

// This value determines how strong gravity's hold on us is.
// The higher the value, the more speed we pick up as we fall.
float ACCELERATION = 1.3;

// and this is the level we'll be playing.
MarioLevel mainLevel, darkLevel, level;

// sprites in this demo are mostly multiples of 16
final int BLOCK = 16;
int screenWidth, screenHeight;

// boilerplate
void setup() {
  //  size(32*BLOCK, 27*BLOCK, (P3Dmode ? P3D : P2D));
  size(32*BLOCK, 27*BLOCK, P2D);
  screenWidth = width;
  screenHeight = height;
  frameRate(30);
  // set up the sound manager
  SoundManager.init(this);
  // It is essential that this is called
  // before any sprites are made:
  SpriteMapHandler.setSketch(this);
  reset();
}

// resetting is important
void reset() {
  level = null;
  SoundManager.reset();
  if (javascript!=null) { 
    javascript.resetActorCount();
  }
  // set up two "persistent" levelsz
  mainLevel = new MainLevel(width, height, 4, 1);
  darkLevel = new DarkLevel(width, height, 1, 1);

  // set up our running level as "main"
  setLevel(mainLevel);
}

void setLevel(MarioLevel newLevel) {
  if (level!=null) {
    SoundManager.stop(level);
    // carry over mario to the new level
    newLevel.updateMario(level.mario);
  }
  level = newLevel;
  SoundManager.loop(level);
}

// Render mario in glorious canvas definition
void draw() {
  if (level.finished && level.swappable) { 
    reset();
  }
  else { 
    level.draw();
  }
  resetMatrix();
  image(SoundManager.volume_overlay, width-20, 4);
  if (javascript!=null) {
    javascript.recordFramerate(frameRate);
  }
}

// pass-through for keyboard events
void keyPressed() { 
  level.keyPressed(key, keyCode);
}
void keyReleased() { 
  level.keyReleased(key, keyCode);
}

void mousePressed() {
  // mute button! very important
  if (mouseX>width-20 && mouseY<20) { 
    SoundManager.mute();
  }
  // normal passthrough
  else { 
    level.mousePressed(mouseX, mouseY, mouseButton);
  }
}

void mouseReleased() {
  level.mouseReleased(mouseX, mouseY, mouseButton);
}

// shortcut method for setting up "game" views
void setGameView() {
  level.showBackground(true);
  level.showBoundaries(false);
  level.showPickups(true);
  level.showDecals(true);
  level.showInteractors(true);
  level.showActors(true);
  level.showForeground(true);
  level.showTriggers(false);
}

// shortcut method for setting up "game design" views
void setDesignView() {
  level.showBackground(false);
  level.showBoundaries(true);
  level.showPickups(true);
  level.showDecals(true);
  level.showInteractors(true);
  level.showActors(true);
  level.showForeground(false);
  level.showTriggers(true);
}

// debug: how many actors are loaded?
int getActorCount() {
  return level.getActorCount();
}