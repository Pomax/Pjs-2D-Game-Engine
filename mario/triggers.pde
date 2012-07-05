/***************************************
 *                                     *
 *             TRIGGERS                *
 *                                     *
 ***************************************/

abstract class MarioTrigger extends Trigger {
  float px, py, ix, iy;
  MarioTrigger(String name, float x, float y, float w, float h, float _px, float _py, float _ix, float _iy) {
    super(name, x, y, w, h);
    px = _px;
    py = _py;
    ix = _ix;
    iy = _iy;
  }
}


/**
 * triggers a koopa trooper 350px to the right
 */
class KoopaTrigger extends MarioTrigger {
  KoopaTrigger(float x, float y, float w, float h, float _px, float _py, float _ix, float _iy) {
    super("koopa", x, y, w, h, _px, _py, _ix, _iy);
  }
  void run(LevelLayer layer, Actor actor, float[] intersection) {
    Koopa k = new Koopa(x+px, py);
    if (fx>0) { 
      k.setHorizontalFlip(true);
    }
    layer.addInteractor(k);
    // remove this trigger so that it's not repeated
    removeTrigger();
  }
}


/**
 * triggers a Banzai Bill!
 */
class BanzaiBillTrigger extends MarioTrigger {
  BanzaiBillTrigger(float x, float y, float w, float h, float _px, float _py, float _ix, float _iy) {
    super("banzai bill", x, y, w, h, _px, _py, _ix, _iy);
  }
  void run(LevelLayer layer, Actor actor, float[] intersection) {
    BanzaiBill b = new BanzaiBill(x+px, py);
    if (fx>0) { b.setHorizontalFlip(true); }
    b.setImpulse(ix, iy);
    layer.addInteractor(b);
    removeTrigger();
  }
}

/**
 * triggers a hidden mushroom
 */
class MushroomTrigger extends MarioTrigger {
  MushroomTrigger(float x, float y, float w, float h, float _px, float _py, float _ix, float _iy) {
    super("mushroom", x, y, w, h, _px, _py, _ix, _iy);
  }
  void run(LevelLayer layer, Actor actor, float[] intersection) {
    Mushroom m = new Mushroom(px, py);
    m.setImpulse(ix, iy);
    m.setForces(0,DOWN_FORCE);
    m.setAcceleration(0,0);
    layer.addForPlayerOnly(m);
    removeTrigger();
  }
}

