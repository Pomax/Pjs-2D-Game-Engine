/**
 * Our main level layer has a background
 * color, and nothing else.
 */
class MainBackgroundLayer extends LevelLayer {
  Mario mario;
  MainBackgroundLayer(Level owner) {
    super(owner, owner.width, owner.height, 0,0, 0.75,0.75);
    addStaticSpriteBG(new TilingSprite(new Sprite("graphics/backgrounds/sky_2.gif"),0,0,width,height));
  }
  void draw() {
    background(color(0, 100, 190));
    super.draw();
  }
}
