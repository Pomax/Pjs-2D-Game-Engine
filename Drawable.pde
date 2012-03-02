/**
 * Any class that implements this interface
 * is able to draw itself ONLY when its visible
 * regions are inside the indicated viewbox.
 */
interface Drawable {
  void draw(float x, float y, float w, float h);
}
