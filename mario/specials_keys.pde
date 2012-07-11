// Keys are handled in two parts - a pickup, which when picked up effects a decal //

/**
 * The decal part of keys
 */
class KeyDecal extends Decal {
  KeyDecal(float x, float y) {
    super("graphics/assorted/Key.gif",x,y);
  }
}

/**
 * The pickup part of keys
 */
class KeyPickup extends MarioPickup {
  KeyPickup(float x, float y) {
    super("Key", "graphics/assorted/Key.gif", 1, 1, x, y, true);
    setForces(0,DOWN_FORCE);
    setAcceleration(0,ACCELERATION);
  }
}


/**
 * The keyhole is also important!
 */
class KeyHole extends Interactor {

  ArrayList<UnlockListener> listeners = new ArrayList<UnlockListener>();
  void addListener(UnlockListener l) { if (!listeners.contains(l)) { listeners.add(l); }}
  void removeListener(UnlockListener l) { listeners.remove(l); }

  KeyHole(float x, float y) {
    super("Keyhole");
    setPosition(x,y);
    setupStates();
  }

  void setupStates() {
    State keyhole = new State("idle","graphics/assorted/Keyhole.gif");
    addState(keyhole);
    keyhole.sprite.align(CENTER,BOTTOM);
  }

  void overlapOccurredWith(Actor other, float[] overlap) {
    super.overlapOccurredWith(other, overlap);
    if (other instanceof Mario) {
      Mario m = (Mario) other;
      if (m.hasKey) {
        m.removeKey();
        for(UnlockListener l: listeners) {
          l.unlocked(m, this);
        }
      }
    }
  }
}

/**
 * keyhole listeners must implement this interface
 */
interface UnlockListener {
  void unlocked(Actor by, KeyHole hole);
}

