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
  void gotBlocked(Boundary b, float[] intersection) {
    if (intersection[0]-x==0 && intersection[1]-y==0) {
      fx = -fx;
      active.sprite.flipHorizontal();
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
 * A delicious powerup mushroom
 */
class Mushroom extends MarioPickup {
  Mushroom(float x, float y) {
    super("Mushroom", "graphics/assorted/Mushroom.gif", 1, 1, x, y, false);
    getState("Mushroom").sprite.align(CENTER, BOTTOM);
    // make mushroom gently slide to the right
    setImpulseCoefficients(0, 0);
    setForces(2, DOWN_FORCE);
    setAcceleration(0, ACCELERATION);
    updatePositioningInformation();
    SoundManager.load(this, "audio/Powerup.mp3");
    persistent = false;
  }
  void pickedUp() { 
    SoundManager.play(this);
  }
}

/**
 * The sought-after fire flower
 */
class Flower extends MarioPickup {
  Flower(float x, float y) {
    super("Flower", "graphics/assorted/Flower.gif", 1, 1, x, y, false);
    getState("Flower").sprite.align(CENTER, BOTTOM);
    SoundManager.load(this, "audio/Powerup.mp3");
    persistent = false;
  }
  void pickedUp() { 
    SoundManager.play(this);
  }
  // most pickups bounce around. Fire flowers don't
  void gotBlocked(Boundary b, float[] intersection) {}
}

/**
 * A fire blob from fire mario.
 * This pickup is interesting because
 * it's a pickup for "not the player".
 */
class FireBlob extends MarioPickup {
  FireBlob(float x, float y, float ix, float iy) {
    super("Fire blob", "graphics/assorted/Flowerpower.gif", 1, 4, x, y, true);
    setImpulse(ix, iy);
    setImpulseCoefficients(1, 1);
    persistent = false;
    // note: no audio when picked up
  }

  // fire blobs disappear when they hit the ground
  void gotBlocked(Boundary b, float[] intersection) {
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
    Sprite s = getState("Finish line").sprite;
    s.align(LEFT, CENTER);
    s.setNoRotation(true);
    s.addPathLine(0, 0, 1, 1, 0, 0, -116, 1, 1, 0, 50);
    s.addPathLine(0, -116, 1, 1, 0, 0, 0, 1, 1, 0, 50);
    SoundManager.load(this, "audio/bg/Course-clear.mp3");
  }

  void pickedUp() {
    SoundManager.play(this);
    level.finish();
  }
}