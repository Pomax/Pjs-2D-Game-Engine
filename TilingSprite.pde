/**
 * Tiling sprite
 */
class TilingSprite extends Positionable {
  Sprite sprite;

  // from where to where?
  float x1, y1, x2, y2;

  /**
   * Set up a sprite to be tiled from x1/y1 to x2/y2 from file
   */
  // FIXME: temporarily commented off, because of a possible bug in Pjs
//  TilingSprite(String spritesheet, float minx, float miny, float maxx, float maxy) {
//    this(new Sprite(spritesheet),minx,miny,maxx,maxy);
//  }

  /**
   * Set up a sprite to be tiled from x1/y1 to x2/y2 from Sprite
   */
  TilingSprite(Sprite _sprite, float minx, float miny, float maxx, float maxy) {
    x1 = minx;
    y1 = miny;
    x2 = maxx;
    y2 = maxy;
    _sprite.align(LEFT, TOP);
    sprite = _sprite;
  }
  
  /**
   * draw this sprite repretitively
   */
  void draw(float vx, float vy, float vw, float vh) {
    // FIXME: we should know what the viewbox transform
    //        is at this point, because it matters for
    //        determining how many sprite blocks to draw.
    float ox = sprite.x, oy = sprite.y, x, y,
          sx = max(x1, vx - (vx-x1)%sprite.width),
          sy = max(y1, vy - (vy-y1)%sprite.height),
          ex = min(x2, vx+2*vw), // ideally, this is vx + vw + {something that ensures the rightmost block is drawn}
          ey = min(y2, vy+2*vh); // ideally, this is vy + vh + {something that ensures the bottommost block is drawn}
    for(x = sx; x < ex; x += sprite.width){
      for(y = sy; y < ey; y += sprite.height){
        sprite.draw(x,y);
      }
    }
  }

  /**
   * Can this object be drawn in this viewbox?
   */
  boolean drawableFor(float vx, float vy, float vw, float vh) {
    // tile drawing will short circuit based on the viewbox.
    return true;
  }

  // unused for tiling sprites
  void drawObject() {}
}
