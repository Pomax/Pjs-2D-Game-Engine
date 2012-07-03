/**
 * Every thing in 2D sprite games happens in "Screen"s.
 * Some screens are menus, some screens are levels, but
 * the most generic class is the Screen class
 */
abstract class Screen {
  // is this screen locked, or can it be swapped out?
  boolean swappable = false;

  // level dimensions
  float width, height;

  /**
   * simple Constructor
   */
  Screen(float _width, float _height) {
    width = _width;
    height = _height;
  }
  
  /**
   * allow swapping for this screen
   */
  void setSwappable() {
    swappable = true; 
  }
 
  /**
   * draw the screen
   */ 
  abstract void draw();
  
  /**
   * perform any cleanup when this screen is swapped out
   */
  abstract void cleanUp();

  /**
   * passthrough events
   */
  abstract void keyPressed(char key, int keyCode);
  abstract void keyReleased(char key, int keyCode);
  abstract void mouseMoved(int mx, int my);
  abstract void mousePressed(int mx, int my, int button);
  abstract void mouseDragged(int mx, int my, int button);
  abstract void mouseReleased(int mx, int my, int button);
  abstract void mouseClicked(int mx, int my, int button);
}
