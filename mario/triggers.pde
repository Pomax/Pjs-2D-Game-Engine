/***************************************
 *                                     *
 *             TRIGGERS                *
 *                                     *
 ***************************************/

/**
 * triggers a koopa trooper 350px to the right
 */
class KoopaTrigger extends Trigger {
  float kx, ky, fx, fy;
  KoopaTrigger(float x, float y, float w, float h, float _kx, float _ky, float _fx, float _fy) {
    super("koopa", x, y, w, h);
    kx = _kx;
    ky = _ky;
    fx = _fx;
    fy = _fy;
  }
  void run(LevelLayer layer, Actor actor, float[] intersection) {
    Koopa k = new Koopa(x+kx, ky);
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
class BanzaiBillTrigger extends Trigger {
  float kx, ky, fx, fy;
  BanzaiBillTrigger(float x, float y, float w, float h, float _kx, float _ky, float _fx, float _fy) {
    super("banzai bill", x, y, w, h);
    kx = _kx;
    ky = _ky;
    fx = _fx;
    fy = _fy;
  }
  void run(LevelLayer layer, Actor actor, float[] intersection) {
    BanzaiBill k = new BanzaiBill(x+kx, ky);
    k.setImpulse(fx, fy);
    layer.addInteractor(k);
    // remove this trigger so that it's not repeated
    removeTrigger();
  }
}
