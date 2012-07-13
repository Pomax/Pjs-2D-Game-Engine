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
  }
}
