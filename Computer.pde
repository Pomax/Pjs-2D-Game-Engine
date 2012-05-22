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

