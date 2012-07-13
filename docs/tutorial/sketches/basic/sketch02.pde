/**
 * We must set the screen dimensions to something
 */
final int screenWidth = 200;
final int screenHeight = 200;

/**
 * initializing means building an "empty"
 * level, which we'll 
 */
void initialize() {
  addScreen("mylevel", new MyLevel(width, height));  
}

/**
 * Our "empty" level is a single layer
 * level, doing absolutely nothing.
 */
class MyLevel extends Level {
  MyLevel(float levelWidth, float levelHeight) {
    super(levelWidth, levelHeight);
    addLevelLayer("my level layer", new MyLevelLayer(this));
  }
}

/**
 * Our main level layer has a background
 * color, and nothing else.
 */
class MyLevelLayer extends LevelLayer {
  MyLevelLayer(Level owner) {
    super(owner);
    color blueish = color(0,130,255);
    setBackgroundColor(blueish);
  }
}