/**
 * Any class that implements this interface
 * is able to draw itself ONLY when its visible
 * regions are inside the indicated viewbox.
 */
interface Drawable {
  /**
   * draw this thing, as long as it falls within the drawbox defined by x/y -- x+w/y+h
   */
  void draw(float x, float y, float w, float h);
}
