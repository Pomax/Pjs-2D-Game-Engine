/**
 * To show level swapping we also have a small "dark"
 * level that is teleport from, and back out of.
 */
class DarkLevel extends MarioLevel
{
  // constructor sets up a level and level layer
  DarkLevel(float w, float h, int x_repeat, int y_repeat)
  {
    super(w*x_repeat, h*y_repeat);
    setViewBox(0, 0, w, h);
    addLevelLayer("color", new BackgroundColorLayer(this, width, height, color(0, 0, 100)));

    LevelLayer layer = new DarkLevelLayer(this, width, height);
    if (layer.players.size()==0 || mario==null) {
      mario = new Mario();
      mario.setPosition(16, height-32);
      mario.setImpulse(0, -24);
      layer.addPlayer(mario);
    }
    addLevelLayer("main", layer);

    // And of course some background music.
    SoundManager.load(this, "audio/bg/Bonus.mp3");
  }
}
