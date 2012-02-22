/**
 * A sprite proxy is an object wrapper for sprites
 * so that the same sprite can be draw a million
 * times with different parameters, while using only
 * a single sprite in memory.
 */
class SpriteProxy {
  // wrapped sprite
  Sprite sprite;

  // proxy frame offset
  int frameOffset=0;

  // path offset
  int pathOffset=0;

  /**
   * Wrap a sprite for drawing on screen
   * without needing a build a new sprite object.
   */
  SpriteProxy(Sprite _sprite) {
    sprite = _sprite;
  }

  /**
   * Set the frame offset for this proxy.
   */
  void setFrameOffset(int offset) {
    frameOffset = offset;
  }

  /**
   * Set the animation path offset for this proxy.
   */
  void setPathOffset(int offset) {
    pathOffset = offset;
  }

  int ofo=sprite.frameOffset;
  int pfo=sprite.path.pathOffset;

  /**
   * Draw sprite with proxy values applied
   */
  void drawObject() {
    int ofo=sprite.frameOffset;
    int pfo=sprite.path.pathOffset;
    
    // 2) apply proxy values and draw
    sprite.frameOffset=frameOffset;
    sprite.path.pathOffset=pathOffset;
    sprite.draw();

    // 3) restore original values
    sprite.frameOffset=ofo;
    sprite.path.pathOffset=pfo;
  }
}
