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
  TilingSprite(Sprite sprite, float minx, float miny, float maxx, float maxy) {
    x1 = minx;
    y1 = miny;
    x2 = maxx;
    y2 = maxy;
    this.sprite = sprite;
  }
  
  /**
   * draw this sprite repretitively
   */
  void draw(float vx, float vy, float vw, float vh) {
    float ox = sprite.x, oy = sprite.y, x, y,
          // FIXME: find out why sx/sy don't work with viewbox dimensions
          sx = x1, //max(vx-vw,x1),
          sy = y1, //max(vy-vh,y1),
          ex = min(x2,vx+2*vw),
          ey = min(y2,vy+2*vh);
    for(x = sx; x < ex; x += sprite.width){
      for(y = sy; y < ey; y += sprite.height){
        sprite.setPosition(x,y);
        sprite.draw(); }}
    sprite.setPosition(ox,oy);
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
