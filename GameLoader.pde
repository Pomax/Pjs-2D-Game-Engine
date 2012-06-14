/**
 * This encodes all the boilerplate code
 * necessary for level drawing and input
 * handling.
 */

// global levels container
HashMap<String, Level> levelSet;

// global 'currently active' level
Level activeLevel = null;

// setup sets up the screen size, and level container,
// then calls the "initialize" method, which you must
// implement yourself.
void setup() {
  size(screenWidth, screenHeight);
  noLoop();

  levelSet = new HashMap<String, Level>();
  SpriteMapHandler.init(this);
  SoundManager.init(this);
  CollisionDetection.init(this);
  initialize();
}

// draw loop
void draw() { activeLevel.draw(); }

// event handling
void keyPressed()    { activeLevel.keyPressed(key, keyCode); }
void keyReleased()   { activeLevel.keyReleased(key, keyCode); }
void mouseMoved()    { activeLevel.mouseMoved(mouseX, mouseY); }
void mousePressed()  { activeLevel.mousePressed(mouseX, mouseY, mouseButton); }
void mouseDragged()  { activeLevel.mouseDragged(mouseX, mouseY, mouseButton); }
void mouseReleased() { activeLevel.mouseReleased(mouseX, mouseY, mouseButton); }
void mouseClicked()  { activeLevel.mouseClicked(mouseX, mouseY, mouseButton); }

/**
 * Mute the game
 */
void mute() { SoundManager.mute(true); }

/**
 * Unmute the game
 */
void unmute() { SoundManager.mute(false); }

/**
 * Levels are added to the game through this function.
 */
void addLevel(String name, Level level) {
  levelSet.put(name, level);
  if (activeLevel == null) {
    activeLevel = level;
    loop();
  }
}

/**
 * We switch between levels with this function.
 *
 * Because we might want to move things from the
 * old level to the new level, this function gives
 * you a reference to the old level after switching.
 */
Level setActiveLevel(String name) {
  Level oldLevel = activeLevel;
  activeLevel = levelSet.get(name);
  return oldLevel;
}

/**
 * Levels can be removed to save memory, etc.
 * as long as they are not the active level.
 */
void removeLevel(String name) {
  if (levelSet.get(name) != activeLevel) {
    levelSet.remove(name);
  }
}

/**
 * Get a specific level (for debug purposes)
 */
Level getLevel(String name) {
  return levelSet.get(name);
}

/**
 * clear all levels
 */
void clearLevels() {
  levelSet = new HashMap<String, Level>();
  activeLevel = null;
}
