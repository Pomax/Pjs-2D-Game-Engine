class BonusBackgroundLayer extends MarioLayer{
  BonusBackgroundLayer(Level parent) {
    super(parent);
    // repeating background sprite image
    Sprite bgsprite = new Sprite("graphics/backgrounds/nightsky_bg.gif");
    bgsprite.align(RIGHT, TOP);
    TilingSprite backdrop = new TilingSprite(bgsprite, 0, 0, width, height);
    addBackgroundSprite(backdrop); 
  }
}
