/***************************************
 *                                     *
 *             TRIGGERS                *
 *                                     *
 ***************************************/


/**
 * triggers a mushroom
 */
class PowerupTrigger extends Trigger {
  PowerupTrigger(float x, float y, float w, float h) {
    super("powerup", x, y, w, h);
  }
  void run(LevelLayer layer, Actor actor, float[] intersection) {
    Mushroom m = new Mushroom(452, 432-49);
    m.setImpulse(0.3, 0);
    layer.addForPlayerOnly(m);
    // remove this trigger so that it's not repeated
    removeTrigger();
  }
}

/**
 * triggers a koopa trooper 350px to the right
 */
class KoopaTrigger extends Trigger {
  float kx, ky, fx, fy;
  KoopaTrigger(float x, float y, float w, float h, float kx, float ky, float fx, float fy) {
    super("koopa", x, y, w, h);
    this.kx = kx;
    this.ky = ky;
    this.fx = fx;
    this.fy = fy;
  }
  void run(LevelLayer layer, Actor actor, float[] intersection) {
    Koopa k = new Koopa(x+kx, ky);
    k.setForces(fx, fy);
    if (fx>0) { 
      k.active.sprite.flipHorizontal();
    }
    k.persistent = false;
    layer.addInteractor(k);
    // remove this trigger so that it's not repeated
    removeTrigger();
  }
}

/**
 * triggers a koopa trooper on top of the slant
 */
class SlantKoopaTrigger extends Trigger {
  SlantKoopaTrigger(float x, float y, float w, float h) {
    super("slant koopa", x, y, w, h);
  }
  void run(LevelLayer layer, Actor actor, float[] intersection) {
    // this puts a slant-koopa at a very specific
    // location, namely on top of the slanted ground.
    Koopa k = new Koopa(296, 288);
    k.addForces(-0.2, 0);
    k.persistent = false;
    layer.addInteractor(k);
    // remove this trigger so that it's not repeated
    removeTrigger();
  }
}

/**
 * triggers a Banzai Bill!
 */
class BanzaiBillTrigger extends Trigger {
  float kx, ky, fx, fy;
  BanzaiBillTrigger(float x, float y, float w, float h, float kx, float ky, float fx, float fy) {
    super("banzai bill", x, y, w, h);
    this.kx = kx;
    this.ky = ky;
    this.fx = fx;
    this.fy = fy;
  }
  void run(LevelLayer layer, Actor actor, float[] intersection) {
    BanzaiBill k = new BanzaiBill(x+kx, ky);
    k.setImpulse(fx, fy);
    k.persistent = false;
    layer.addInteractor(k);
    // remove this trigger so that it's not repeated
    removeTrigger();
  }
}

/**
 * Tube trigger
 */
class TeleportTrigger extends Trigger {
  float tx, ty;
  Boundary lid;
  TeleportTrigger(float x, float y, float w, float h, float tx, float ty) {
    super("teleporter", x, y, w, h);
    this.tx = tx;
    this.ty = ty;
  }
  void setLid(Boundary lid) { 
    this.lid = lid;
  }
  void run(LevelLayer layer, Actor actor, float[] intersection) {
    // spit mario back out
    actor.setPosition(tx, ty);
    actor.setImpulse(0, 0);
    lid.enable();
  }
}

/**
 * Tube trigger
 */
class LayerTeleportTrigger extends TeleportTrigger {
  String target;
  LayerTeleportTrigger(float x, float y, float w, float h, float tx, float ty, String target) {
    super(x, y, w, h, tx, ty);
    this.target = target;
  }
  void run(LevelLayer layer, Actor actor, float[] intersection) {
    layer.removePlayer((Player)actor);
    level.getLevelLayer(target).addPlayer((Player)actor);
    actor.setPosition(tx, ty);
    actor.setImpulse(0, 0);
    lid.enable();
  }
}

/**
 * Tube trigger, with the target tube pointing upward
 */
class LayerTeleportTriggerUp extends TeleportTrigger {
  String target;
  LayerTeleportTriggerUp(float x, float y, float w, float h, float tx, float ty, String target) {
    super(x, y, w, h, tx, ty);
    this.target = target;
  }
  void run(LevelLayer layer, Actor actor, float[] intersection) {
    layer.removePlayer((Player)actor);
    level.getLevelLayer(target).addPlayer((Player)actor);
    actor.setPosition(tx, ty+24);
    actor.setImpulse(0, -20);
    lid.enable();
  }
}


/***************************************
 *                                     *
 *        LEVEL TELEPORTERS            *
 *                                     *
 ***************************************/


/**
 * to the dark bonus level
 */
class BonusLevelTrigger extends TeleportTrigger {
  BonusLevelTrigger(float x, float y, float w, float h, float tx, float ty) { 
    super(x, y, w, h, tx, ty);
  }
  void run(LevelLayer layer, Actor actor, float[] intersection) {
    // make sure mario's in the right place
    actor.setPosition(16, darkLevel.height-32);
    actor.setImpulse(0, -24);
    // switch to bonus level
    setLevel(darkLevel);
    // seal tube
    lid.enable();
  }
}

/**
 * back to main level 
 */
class MainLevelTrigger extends TeleportTrigger {
  MainLevelTrigger(float x, float y, float w, float h, float tx, float ty) { 
    super(x, y, w, h, tx, ty);
  }
  void run(LevelLayer layer, Actor actor, float[] intersection) {
    // make sure mario's in the right place
    actor.setPosition(tx, ty);
    // switch back to main level
    setLevel(mainLevel);
    // seal tube
    lid.enable();
  }
}
