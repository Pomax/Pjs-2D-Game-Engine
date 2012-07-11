/**
 * Bonus!
 */
class BonusLevel extends MarioLevel
{
  BonusLevel(float w, float h)
  {
    super(w, h);
    addLevelLayer("Background Layer", new BackgroundColorLayer(this, color(24,48,72)));
    addLevelLayer("Star Layer", new BonusBackgroundLayer(this));

    LevelLayer layer = new BonusLayer(this);
    addLevelLayer("Bonus Layer", layer);
    mario.setPosition(width/2, height-32);
    layer.addPlayer(mario);

    SoundManager.load(this, "audio/bg/Bonus.mp3");
  }
  
  void updateMario(Player p) {
    super.updateMario(p);
    mario.setPosition(width/2, height-32);
  }
}
