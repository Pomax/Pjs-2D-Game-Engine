/***************************************
 *                                     *
 *      INTERACTORS: RED KOOPA         *
 *                                     *
 ***************************************/


/**
 * A red koopa trooper actor
 */
class Koopa extends Interactor {

  /**
   * The constructor for the koopa trooper
   * is essentially the same as for Mario.
   */
  Koopa(float mx, float my) {
    super("Red koopa", DAMPENING, DAMPENING);
    setPosition(mx, my);
    setForces(0, DOWN_FORCE);
    setAcceleration(0, ACCELERATION);
    setupStates();
  }

  /**
   * So, what can koopa troopers do?
   */
  void setupStates() {
    // when walking around
    State walking = new State("walking", "graphics/enemies/Red-koopa-walking.gif", 1, 2);
    walking.sprite.align(CENTER, BOTTOM);
    walking.sprite.setAnimationSpeed(0.25);
    addState(walking);

    // when just standing, doing nothing
    State standing = new State("standing", "graphics/enemies/Red-koopa-standing.gif", 1, 2);
    standing.sprite.align(CENTER, BOTTOM);
    addState(standing);

    // if we get squished, we first get naked...
    State naked = new State("naked", "graphics/enemies/Naked-koopa-walking.gif", 1, 2);
    naked.sprite.setAnimationSpeed(0.25);
    naked.sprite.align(CENTER, BOTTOM);
    SoundManager.load(naked, "audio/Squish.mp3");
    addState(naked);

    // if we get squished again, we die!
    State dead = new State("dead", "graphics/enemies/Dead-koopa.gif");
    dead.sprite.align(CENTER, BOTTOM);
    dead.sprite.addPathLine(0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 12);
    dead.sprite.setLooping(false);
    SoundManager.load(dead, "audio/Squish.mp3");
    addState(dead);

    // by default, the koopa will be walking
    setCurrentState("walking");
  }

  /**
   * Mario squished us! O_O
   *
   * Should we just lose our shell, or have we
   * been properly squished dead?
   */
  boolean squish() {
    // if we're scheduled for removal,
    // don't do anything.
    if (remove) return false;

    // We're okay, we just lost our shell.
    if (active.name != "naked" && active.name != "dead") {
      setCurrentState("naked");
      SoundManager.play(active);
      // trigger some hitpoints
      layer.addDecal(new HitPoints(x, y, 100));

      // mario should jump after trying to squish us
      return true;
    }

    // Ohnoes! we've been squished properly!
    // make sure we stop moving forward
    setForces(0, 0);
    setInteracting(false);
    setCurrentState("dead");
    SoundManager.play(active);
    // trigger some hitpoints
    layer.addDecal(new HitPoints(x, y, 200));
    // mario should also jump after squishing us dead
    return true;
  }

  /**
   * "when state finishes" behaviour: when the
   * "blargh, I am dead!" state is done, we need
   * to remove this koopa from the game.
   */
  void handleStateFinished(State which) {
    if (which.name=="dead") {
      removeActor();
    }
  }

  /**
   * Turn around when we walk into a wall
   */
  void gotBlocked(Boundary b, float[] intersection) {
    if (intersection[0]-x==0 && intersection[1]-y==0) {
      fx = -fx;
      active.sprite.flipHorizontal();
    }
  }

  void pickedUp(Pickup p) {
    squish();
  }
}