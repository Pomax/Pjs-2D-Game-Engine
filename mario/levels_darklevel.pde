/**
 * To show level swapping we also have a small "dark"
 * level that is teleport from, and back out of.
 */
class DarkLevel extends MarioLevel
{
  // constructor sets up a level and level layer
  DarkLevel(float w, float h)
  {
    super(w, h);
    addLevelLayer("color", new BackgroundColorLayer(this, color(0, 0, 100)));

    LevelLayer layer = new DarkLevelLayer(this);
    addLevelLayer("main", layer);
    mario.setPosition(16,height-80);
    layer.addPlayer(mario);

    // And of course some background music.
    SoundManager.load(this, "audio/bg/Bonus.mp3");
  }
}
