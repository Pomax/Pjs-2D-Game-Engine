/***************************************
 *                                     *
 *   INTERACTORS: THE COIN BLOCK BOO   *
 *                                     *
 ***************************************/


/**
 * A coin block Boo! It acts like a normal
 * coin block, until you turn your back...
 * then it turns into a Boo and chases you!
 */
class CoinBlockBoo extends CoinBlock implements Tracker {
  boolean isBoo = false;

  /**
   * Sneakily, a coin block Boo is
   * the same as a normal coin block.
   */
  CoinBlockBoo(float x, float y) {
    super(x, y);
    setImpulseCoefficients(DAMPENING, DAMPENING);
    setPlayerInteractionOnly(true);
  }

  /**
   * Of course, a coin block Boo
   * has a few more states than a
   * normal coin block.
   */
  void setupStates() {
    super.setupStates();

    // an important state is the "from block to boo" state
    State transition = new State("transition", "graphics/enemies/Coin-boo-transition.gif", 1, 5);
    transition.sprite.setAnimationSpeed(0.4);
    transition.sprite.setLooping(false);
    transition.sprite.addPathPoint(0, 0, 1, 1, 0, 10);
    addState(transition);

    State chasing = new State("chasing", "graphics/enemies/Boo-chasing.gif");
    addState(chasing);

    setCurrentState("hanging");
  }

  /**
   * When we get bricked, give Mario 1000 points
   */
  void setCurrentState(String name) {
    super.setCurrentState(name);
    if (name=="exhausted") {
      // trigger some hitpoints
      layer.addDecal(new HitPoints(x, y, 1000));
    }
  }

  /**
   * Transition to boo-ness
   */
  void handleStateFinished(State which) {
    super.handleStateFinished(which);
    if (which.name=="transition") {
      disableBoundaries();
      setCurrentState("chasing");
      isBoo = true;
    }
  }

  /**
   * How do we deal with tracking?
   * - if we're a coin block, and we can chase, first become a Boo
   * - if we're a Boo, and mario doesn't look at us, chase.
   */
  void track(Actor actor, float vx, float vy, float vw, float vh) {
    // if we got bricked, we never become a Boo =(
    if (active.name=="exhausted") return;

    // if we're pretending to be a coin block, and mario's
    // standing on us, don't blow our cover either.
    if (active.name=="hanging" && havePassenger()) return;

    // if we're too far away, don't track
    if (x<vx-vw || x>vx+vw*2 || y<vy-vh || y>vy+vh*2) return;

    // otherwise: is mario not looking at us?
    if (notLookedAtBy(actor)) {
      // He is! but we're not a Boo yet... become one.
      if (!isBoo) { 
        setCurrentState("transition");
      }

      // We're a Boo! And Mario's not looking! Chase him~!
      else {
        if (active.name != "chasing") {
          setCurrentState("chasing");
        }
        GenericTracker.track(this, actor, 0.3);
      }
    }

    // Uh-oh, he's looking at us...
    else if (active.name == "chasing") {
      isBoo = false;
      enableBoundaries();
      setHorizontalFlip(false);
      setCurrentState("hanging");
    }
  }

  /**
   * Is this actor looking at us?
   */
  boolean notLookedAtBy(Actor actor) {
    // if the actor hasn't moved yet, shortcircuit
    if (actor.direction==-1) return false;
    // if the actor jumped up/down, we pretend it's
    // looking at us if we were already chasing.
    if (actor.direction==PI/2 || actor.direction==PI+PI/2) { 
      return (active.name=="chasing");
    }
    // now the real check: where are we relative to the actor:
    float dx = x - actor.x;
    // and what does that mean for the actor's direction?
    if (dx > 0 && abs(actor.direction-PI)<0.5*PI) {
      // float left
      setHorizontalFlip(true);
      return true;
    }
    if (dx < 0 && abs(actor.direction-PI)>0.5*PI) {
      // float right
      setHorizontalFlip(false);
      return true;
    }
    return false;
  }

  /**
   * When we hit an actor as a Boo, they die.
   */
  void overlapOccurredWith(Actor other, float[] overlap) {
    super.overlapOccurredWith(other, overlap);
    if (isBoo && other instanceof Mario) {
      ((Mario)other).die();
    }
  }
}