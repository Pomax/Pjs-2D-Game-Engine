/**
 * Background with level layer
 */
class BackgroundLayer extends MarioLayer {
  // fairly simple constructor
  BackgroundLayer(Level parent, float w, float h, float ox, float oy, float sx, float sy) {
    super(parent, w, h, ox, oy, sx, sy);

    // repeating background sprite image
    Sprite bgsprite = new Sprite("graphics/backgrounds/sky_2.gif");
    bgsprite.align(RIGHT, TOP);
    TilingSprite backdrop = new TilingSprite(bgsprite, 0, 0, width, height);
    addStaticSpriteBG(backdrop);

    // flat ground
    addBottom("ground", 0, height+8, width, 16);

    // teleport-in tube
    addUpsideDownTube(64, -16);
    // teleport-out tube
    addTube(64, height, new LayerTeleportTriggerUp(64+8, height-24, 16, 2, 594, 335, "main"));

    // coin block boos! O_O
    for(int x = 384; x < width-176; x+=48) {
      addBoundedInteractor(new CoinBlockBoo(x, height - 1*48));
    }

    // goal
    addGoal(width-64, height+8);
  }
}
