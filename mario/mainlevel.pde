/**
 * Our "empty" level is a single layer
 * level, doing absolutely nothing.
 */
class MainLevel extends Level {
  MainLevel(float levelWidth, float levelHeight) {
    super(levelWidth, levelHeight);
    addLevelLayer("background layer", new MainBackgroundLayer(this));
    addLevelLayer("main layer", new MainLevelLayer(this));
    setViewBox(0,0,screenWidth,screenHeight);
    // And of course some background music!
    SoundManager.load(this, "audio/bg/Overworld.mp3");
    SoundManager.play(this);
  }
}
