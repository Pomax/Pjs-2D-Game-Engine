/**
 * This encodes all the boilerplate code
 * necessary for screen drawing and input
 * handling.
 */

// global screens container
HashMap<String, Screen> screenSet;

// global 'currently active' screen
Screen activeScreen = null;

// setup sets up the screen size, and screen container,
// then calls the "initialize" method, which you must
// implement yourself.
void setup() {
  size(screenWidth, screenHeight);
  noLoop();

  screenSet = new HashMap<String, Screen>();
  SpriteMapHandler.init(this);
  SoundManager.init(this);
  CollisionDetection.init(this);
  initialize();
}

// draw loop
void draw() { 
  activeScreen.draw(); 
  SoundManager.draw();
}

// event handling
void keyPressed()    { activeScreen.keyPressed(key, keyCode); }
void keyReleased()   { activeScreen.keyReleased(key, keyCode); }
void mouseMoved()    { activeScreen.mouseMoved(mouseX, mouseY); }
void mousePressed()  { SoundManager.clicked(mouseX,mouseY); activeScreen.mousePressed(mouseX, mouseY, mouseButton); }
void mouseDragged()  { activeScreen.mouseDragged(mouseX, mouseY, mouseButton); }
void mouseReleased() { activeScreen.mouseReleased(mouseX, mouseY, mouseButton); }
void mouseClicked()  { activeScreen.mouseClicked(mouseX, mouseY, mouseButton); }

/**
 * Mute the game
 */
void mute() { SoundManager.mute(true); }

/**
 * Unmute the game
 */
void unmute() { SoundManager.mute(false); }

/**
 * Screens are added to the game through this function.
 */
void addScreen(String name, Screen screen) {
  screenSet.put(name, screen);
  if (activeScreen == null) {
    activeScreen = screen;
    loop();
  } else { SoundManager.stop(activeScreen); }
}

/**
 * We switch between screens with this function.
 *
 * Because we might want to move things from the
 * old screen to the new screen, this function gives
 * you a reference to the old screen after switching.
 */
Screen setActiveScreen(String name) {
  Screen oldScreen = activeScreen;
  activeScreen = screenSet.get(name);
  if (oldScreen != null) {
    oldScreen.cleanUp();
    SoundManager.stop(oldScreen);
  }
  SoundManager.loop(activeScreen);
  return oldScreen;
}

/**
 * Screens can be removed to save memory, etc.
 * as long as they are not the active screen.
 */
void removeScreen(String name) {
  if (screenSet.get(name) != activeScreen) {
    screenSet.remove(name);
  }
}

/**
 * Get a specific screen (for debug purposes)
 */
Screen getScreen(String name) {
  return screenSet.get(name);
}

/**
 * clear all screens
 */
void clearScreens() {
  screenSet = new HashMap<String, Screen>();
  activeScreen = null;
}
