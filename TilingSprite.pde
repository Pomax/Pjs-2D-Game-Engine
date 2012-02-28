/**
 * Tiling sprite
 */
class TilingSprite extends Positionable {
  Sprite sprite;

  // from where to where?
  float x1, y1, x2, y2;

  /**
   * Set up a sprite to be tiled from x1/y1 to x2/y2
   */
  TilingSprite(Sprite _sprite, float minx, float miny, float maxx, float maxy) {
    sprite = _sprite;
    x1 = minx;
    y1 = miny;
    x2 = maxx;
    y2 = maxy;
  }

  /**
   * draw this sprite repretitively
   */
  void draw(){
    float ox = sprite.x, oy = sprite.y;
    float x, y;
    for(x = x1; x < x2; x += sprite.width){
      for(y = y1; y < y2; y += sprite.height){
        sprite.setPosition(x,y);
        sprite.draw();
      }
    }
    sprite.setPosition(ox,oy);
  }

  // unused for tiling sprites
  void drawObject() {}
}
