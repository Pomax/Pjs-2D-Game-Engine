/**
 * Test level implementation
 */
class MainLevel extends MarioLevel {

  // constructor sets up a level and level layer
  MainLevel(float w, float h, int x_repeat, int y_repeat)
  {
    super(w*x_repeat, h*y_repeat);
    setViewBox(0, 0, w, h);
    LevelLayer layer;

    layer = new BackgroundColorLayer(this, width, height, color(0, 100, 190));
    addLevelLayer("color", layer);

    float scaleFactor = 0.75;
    layer = new BackgroundLayer(this, width + (scaleFactor*w/2) /* HACK! */ - 21, height, 0, 0, scaleFactor, scaleFactor);
    addLevelLayer("background 1", layer);

    layer = new MainLevelLayer(this, width, height);
    if (layer.players.size()==0 || mario == null) {
      mario = new Mario();
      mario.setPosition(32, 383);
      layer.addPlayer(mario);
    }
    addLevelLayer("main", layer);

    // And of course some background music.
    SoundManager.load(this, "audio/bg/Overworld.mp3");
  }
  
  void draw() {
    super.draw();
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