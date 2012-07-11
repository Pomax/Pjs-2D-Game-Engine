/**
 * We must set the screen dimensions to something
 */
final int BLOCK = 16,
          screenWidth = 32*BLOCK,
          screenHeight = 27*BLOCK;

/**
 * Gravity consists of a uniform downforce,
 * and a gravitational acceleration
 */
float DOWN_FORCE = 2;
float ACCELERATION = 1.3;
float DAMPENING = 0.75;


/**
 * initializing means building an "empty"
 * level, which we'll 
 */
void initialize() {
  SoundManager.mute(true);
  SoundManager.setDrawPosition(screenWidth-10, 10);
  frameRate(30);
  reset();
}

void reset() {
  clearScreens();
  addScreen("Bonus Level", new BonusLevel(width, height));
  addScreen("Dark Level", new DarkLevel(width, height));
  addScreen("Main Level", new MainLevel(4*width, height));  
  if(javascript != null) { javascript.reset(); }
  setActiveScreen("Main Level");
}

