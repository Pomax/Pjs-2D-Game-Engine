/**
 * Decals cannot be interacted with in any way.
 * They are things like the number of points on
 * a hit, or the dust when you bump into something.
 * Decals run through one state, and then expire,
 * so they're basically triggered, temporary graphics.
 */
class Decal extends Sprite {

  // indicates whether to kill off this decal
  boolean remove = false;
  
  // indicates whether this is an auto-expiring decal
  boolean expiring = false;

  // indicates how long this decal should live
  protected int duration = -1;
  
  // decals can be owned by something
  Positionable owner = null;

  /**
   * non-expiring constructor
   */
  Decal(String spritesheet, float x, float y) {
    this(spritesheet, x, y, false, -1);
  }
  Decal(String spritesheet, int rows, int columns, float x, float y) {
    this(spritesheet, rows, columns, x, y, false, -1);
  }
  /**
   * expiring constructor
   */
  Decal(String spritesheet, float x, float y, int duration) {
    this(spritesheet, x, y, true, duration);
  }
  Decal(String spritesheet, int rows, int columns, float x, float y, int duration) {
    this(spritesheet, rows, columns, x, y, true, duration);
  }
  
  /**
   * full constructor (1 x 1 spritesheet)
   */
  private Decal(String spritesheet, float x, float y, boolean expiring, int duration) {
    this(spritesheet, 1, 1, x, y, expiring, duration);
  }

  /**
   * full constructor (n x m spritesheet)
   */
  private Decal(String spritesheet, int rows, int columns, float x, float y, boolean expiring, int duration) {
    super(spritesheet, rows, columns);
    setPosition(x,y);
    this.expiring = expiring;
    this.duration = duration;
    if(expiring) { setPath(); }
  }

  /**
   * subclasses must implement the path on which
   * decals travel before they expire
   */
  void setPath() {}
  
  /**
   * decals can be owned, in which case they inherit their
   * position from their owner.
   */
  void setOwner(Positionable owner) {
    this.owner = owner;
  }

  // PREVENT PJS FROM GOING INTO AN ACCIDENTAL HIERARCHY LOOP
  void draw() { super.draw(); }
  void draw(float x, float y) { super.draw(x,y); }

  /**
   * Once expired, decals are cleaned up in Level
   */
  void draw(float vx, float vy, float vw, float vh) {
    if(!expiring || duration-->0) {
      super.draw(); 
    }
    else { 
      remove = true; 
    }
  }
}
