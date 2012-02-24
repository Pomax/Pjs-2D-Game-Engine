/**
 * central repository for Sprites
 */
class SpriteFactor {
  HashMap<String,Sprite> sprites = new HashMap<String,Sprite>();

  /**
   * add a sprite to the set of available sprites
   */
  void addSprite(String name, String sheet, int rows, int columns) {
    sprites.put(name, new Sprite(sheet, rows, columns));
  }

  /**
   * get a sprite, wrapped by a sprite proxy
   */
  SpriteProxy getSprite(String name) {
    return new SpriteProxy(sprites.get(name));
  }
}
