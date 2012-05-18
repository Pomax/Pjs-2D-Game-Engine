/***************************************
 *                                     *
 *              DECALS                 *
 *                                     *
 ***************************************/


/**
 * Uses the Decal class to show points
 * earned for jumping on enemies.
 */
class HitPoints extends Decal {
  // create a points text
  HitPoints(float x, float y, int points) {
    super("graphics/decals/"+points+".gif", x, y-16, 12);
  }
  // path: straight up, 64 pixels
  void setPath() {
    addPathLine(0, 0, 1, 1, 0, 
    0, 32, 1, 1, 0, 
    duration);
  }
}
