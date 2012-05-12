/**
 * A static computation class.
 *
 * At the moment this houses the actor/boundary interaction
 * code. This is in its own class, because Processing does
 * not allow you to mix static and non-static code in classes
 * (for the simple reason that all classes are internally
 * compiled into private classes, which cannot be static,
 * so any static class is lifted out of the Sketch code,
 * and it can't do that if you mix regular and static).
 */
static class Computer {

  /**
   * Perform actor/boundary collision detection
   */
  static void interact(Boundary b, Actor a) {
    // skip if this is one of the actor's own boundary.
    if(a.boundaries.contains(b)) { return; }

    // Determine whether our path is blocked.
    float[] intersection = b.blocks(a);
    
    if(intersection!=null) {
      float ix=a.ix, iy=a.iy;
      a.stop(intersection[0], intersection[1]);
      a.attachTo(b);

      float[] rdf = b.redirectForce(ix, iy);
      // FIXME: this hack overcomes an odd deficiency caused
      //        by the way actors and boundaries interact.
      //        Using either value set causes problems:
      //
      //        - addImpulse(ix/iy) makes us momentarily glued
      //        to boundaries that we should bounce off off,
      //        while our impulse is dampened over X frames.
      //
      //        - addImpulse(rdf[0],rdf[1]) correctly kills our
      //        momentum, but also allows us to pass through
      //        certain boundaries (i.e. left side of pipe),
      //        and makes walking to adjacent, connected,
      //        platforms near-impossible.
      //
      //        I would love to find out why, but do not have
      //        have the time to do so right now. I wasted
      //        roughly half a day doing a rewrite of the
      //        boundary/actor system, and ended up throwing
      //        it away because it kept breaking more than it
      //        fixed. This shows two things: this bug is big,
      //        and the process of boundary collision is wrong.
      //
      //        CAUSES: Positionable.update interprets boundary's
      //                redirectForce[2] as an "is on boundary"
      //                value, while in fact it only indicates
      //                whether forces are changed or not.
      a.addImpulse(0.01 * ix + 0.99 * rdf[0],
                   0.01 * iy + 0.99 * rdf[1]);

      a.update();
      // process the block at the actor
      a.gotBlocked(b, intersection);
    }
  }
  

  static boolean debug = false;
  static int _actors = 0, _states = 0, _positionables = 0, _sprites = 0, _arraylists = 0, _hashmaps = 0;
  static void actors() { if(debug) { ts("Actor"); _actors++; }}
  static void states() { if(debug) { ts("State"); _states++; }}
  static void positionables() { if(debug) { ts("Positionable"); _positionables++; }}
  static void sprites() { if(debug) { ts("Sprite"); _sprites++; }}
  static void arraylists(String t) { if(debug) { ts("ArrayList<"+t+">"); _arraylists++; }}
  static void hashmaps(String t, String e) { if(debug) { ts("HashMap<"+t+","+e+">"); _hashmaps++; }}

  // time stamping log function
  static void ts(String s) { 
//    return "["+Date.now()+"] " + s; 
  }
  
/*  
  static void create(String name, String type, int line) {
    if(typeof PJScreates[type] === "undefined") {
      PJScreates[type] = [];
    }
    PJScreates[type].push(ts(name + "[" + line + "]"));
  }
*/
}

