/**
 * Possible the simplest class...
 * A viewbox simply defines a region of
 * interest that is used for render limits.
 * Anything outside the viewbox is not drawn,
 * (although it might still interact), and
 * anything inside the viewbox is shown.
 */
class ViewBox {

  // viewbox values
  float x=0, y=0, w=0, h=0;
  
  ViewBox() {}
  ViewBox(float _w, float _h) { w = _w; h = _h; }
  ViewBox(float _x, float _y, float _w, float _h) { x = _x; y = _y; w = _w; h = _h; }
  String toString() { return x+"/"+y+" - "+w+"/"+h; }

  // current layer transform values
  float llox=0, lloy=0, llsx=1, llsy=1;

  // ye olde getterse
  float getX()      { return x-llox; }
  float getY()      { return y-lloy; }
  float getWidth()  { return w*llsx; }
  float getHeight() { return h*llsy; }

  // the level layer transforms for the layer
  // that the viewbox is currently used by,
  // to determine whether or not to draw things
  // because they are "in view" or not
  void setLevelLayer(LevelLayer layer) {
    if (layer.nonstandard) {
      llox = layer.xTranslate;
      lloy = layer.yTranslate;
      llsx = layer.xScale;
      llsy = layer.yScale;
    }
  }

  /**
   * Reposition the viewbox, based on where
   * our main actor is located on the screen.
   * We need to make sure we never make the
   * viewbox run past the level edges, and
   * in order to make sure of that, we need
   * to transfrom the actor's coordinates
   * to screen coordinates, based on the
   * coordinate transform for the level layer
   * the actor is in.
   */
  void track(Level level, Actor who) {
    setLevelLayer(who.getLevelLayer());

    // FIXME: This does not work quite right!
    //        We leave things as they are so
    //        actors are positioned at scale*midpoint

    // Get actor coordinates, transformed to screen
    // coordinates, and forced to integer values.
    float ax = round(who.getX()),
          ay = round(who.getY());

    // Ideally the actor is in the center of the viewbox,
    // but the level edges may require different positioning.
    float idealx = ax - w/2,
          idealy = ay - h/2;

    // set values based on visual constraints
    x = min( max(0,idealx), level.width - w );
    y = min( max(0,idealy), level.height - h );
  }
}

