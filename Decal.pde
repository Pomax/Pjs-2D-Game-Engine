/**
 * Decals cannot be interacted with in any way.
 * They are things like the number of points on
 * a hit, or the dust when you bump into something.
 * Decals run through one state, and then expire,
 * so they're basically triggered, temporary graphics.
 */
abstract class Decal extends Sprite {
  boolean remove = false;
  protected int duration;

  /**
   * Decals have spritesheets and position
   */
  Decal(String spritesheet, float x, float y, int duration) {
    super(spritesheet);
    setPosition(x,y);
    this.duration = duration;
    setPath();
  }

  /**
   * subclasses must implement the path on which
   * decals travel before they expire
   */
  abstract void setPath();

  /**
   * Once expired, decals are cleaned up in Level
   */
  void draw(float vx, float vy, float vw, float vh) {
    if(duration-->0) {
      super.draw(); 
    }
    else { remove = true; }
  }
}
