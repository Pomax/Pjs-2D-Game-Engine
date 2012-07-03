/**
 * Our "empty" level is a single layer
 * level, doing absolutely nothing.
 */
class MainLevel extends MarioLevel {
  MainLevel(float levelWidth, float levelHeight) {
    super(levelWidth, levelHeight);

    // background
    addLevelLayer("background layer", new MainBackgroundLayer(this));

    // main level layer
    LevelLayer layer = new MainLevelLayer(this);
    addLevelLayer("main layer", layer);

    // make sure there's a Mario
    if (layer.players.size()==0 || mario == null) {
      mario = new Mario();
      mario.setPosition(32, 372);
      layer.addPlayer(mario);
    }

    // And of course some background music!
    SoundManager.load(this, "audio/bg/Overworld.mp3");
  }

  /**
   * If mario loses, we must end the level prematurely:
   */
  void end() {
    SoundManager.pause(this);
    super.end();
  }

  /**
   * But if he wins, we end the level properly:
   */
  void finish() {
    SoundManager.pause(this);
    super.finish();
  }  
}
