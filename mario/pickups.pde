/***************************************
 *                                     *
 *              PICKUPS                *
 *                                     *
 ***************************************/


/**
 * All pickups in Mario may move, and if
 * they do, they will bounce when hitting
 * a clean boundary.
 */
class MarioPickup extends Pickup {
  MarioPickup(String name, String spritesheet, int rows, int columns, float x, float y, boolean visible) {
    super(name, spritesheet, rows, columns, x, y, visible);
  }
  // default horizontal bounce
  void gotBlocked(Boundary b, float[] intersection, float[] original) {
    if (b.x==b.xw) {
      ix = -original[0];
      fx = -fx;
      active.sprite.flipHorizontal();
      detachFrom(b);
    }
  }
}

/**
 * A regular coin
 */
class Coin extends MarioPickup {
  Coin(float x, float y) {
    super("Regular coin", "graphics/assorted/Regular-coin.gif", 1, 4, x, y, true);
    SoundManager.load(this, "audio/Coin.mp3");
  }
  void pickedUp() { 
    SoundManager.play(this);
  }
}

/**
 * A dragon coin!
 */
class DragonCoin extends MarioPickup {
  DragonCoin(float x, float y) {
    super("Dragon coin", "graphics/assorted/Dragon-coin.gif", 1, 10, x, y, true);
    SoundManager.load(this, "audio/Dragon coin.mp3");
  }
  void pickedUp() { 
    SoundManager.play(this);
  }
}

/**
 * A mushroom powerup
 */
class Mushroom extends MarioPickup {
  Mushroom(float x, float y) {
    super("Mushroom", "graphics/assorted/Mushroom.gif", 1, 1, x, y, true);
    SoundManager.load(this, "audio/Powerup.mp3");
    setAcceleration(0,0);
  }
  void pickedUp() { 
    SoundManager.play(this);
  }
}

/**
 * A fire flower powerup
 */
class FireFlower extends MarioPickup {
  FireFlower(float x, float y) {
    super("Fire flower", "graphics/assorted/Flower.gif", 1, 1, x, y, true);
    SoundManager.load(this, "audio/Powerup.mp3");
  }
  void pickedUp() { 
    SoundManager.play(this);
  }
}

/**
 * A fire blob
 */
class FireBlob extends MarioPickup {
  FireBlob(float x, float y) {
    super("Fire blob", "graphics/assorted/Flowerpower.gif", 1, 4, x, y, false);
    SoundManager.load(this, "audio/Squish.mp3");
    persistent = false;
  }
  void pickedUp() { 
    SoundManager.play(this);
  }
  void overlapOccurredWith(Actor other) {
    super.overlapOccurredWith(other);
    other.removeActor();
  }
  void gotBlocked(Boundary b, float[] intersection, float[] original) {
    removeActor();
  }
}

/**
 * The finish line is also a pickup,
 * and will trigger the "clear" state
 * for the level when picked up.
 */
class Rope extends MarioPickup {
  Rope(float x, float y) {
    super("Finish line", "graphics/assorted/Goal-slider.gif", 1, 1, x, y, true);
    State st = getState("Finish line");
    st.addPathLine(0, 0,     0, -116, 50);
    st.addPathLine(0, -116,  0, 0,    50);
    st.setLooping(true);
    Sprite spr = st.sprite;
    spr.align(LEFT, TOP);
    spr.setNoRotation(true);
    SoundManager.load(this, "audio/bg/Course-clear.mp3");
  }

  void pickedUp() {
    // stop background music!
    SoundManager.stop(getLevelLayer().getLevel());
    // play victory music!
    SoundManager.play(this);
  }
}
