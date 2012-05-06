/**
 * This class defines a generic sprite engine level.
 * A layer may consist of one or more layers, with
 * each layer modeling a 'self-contained' slice.
 * For top-down games, these slices yield pseudo-height,
 * whereas for side-view games they yield pseudo-depth.
 */
abstract class Level {
  boolean finished  = false;
  boolean swappable = false;

  ArrayList<LevelLayer> layers = new ArrayList<LevelLayer>();
  HashMap<String, Integer> layerids = new HashMap<String, Integer>();

  // level dimensions
  float width, height;

  // current viewbox
  ViewBox viewbox = new ViewBox();

  /**
   * Levels have dimensions!
   */
  Level(float _width, float _height) {
    width = _width;
    height = _height; 
  }

  /**
   * The viewbox only shows part of the level,
   * so that we don't waste time computing things
   * for parts of the level that we can't even see.
   */
  void setViewBox(float _x, float _y, float _w, float _h) {
    viewbox.x = _x;
    viewbox.y = _y;
    viewbox.w = _w;
    viewbox.h = _h;
  }

  void addLevelLayer(String name, LevelLayer layer) {
    layerids.put(name,layers.size());
    layers.add(layer);
  }

  LevelLayer getLevelLayer(String name) {
    return layers.get(layerids.get(name));
  }
  
  // FIXME: THIS IS A TEST FUNCTION. KEEP? REJECT?
  void updatePlayer(Player oldPlayer, Player newPlayer) {
    for(LevelLayer l: layers) {
      l.updatePlayer(oldPlayer, newPlayer);
    }
  }

  /**
   * Change the behaviour when the level finishes
   */
  void finish() { finished = true; }

  /**
   * premature finish
   */
  void end() { finished = true; swappable = true; }
  
  /**
   * Allow this level to be swapped out
   */
  void setSwappable() { swappable = true; } 

  /**
   * draw the level, as seen from the viewbox
   */
  void draw() {
    translate(-viewbox.x, -viewbox.y);
    for(LevelLayer l: layers) {
      l.draw();
    }
  }
  
  // used for statistics
  int getActorCount() {
    int count = 0;
    for(LevelLayer l: layers) { count += l.getActorCount(); }
    return count;
  }

  /**
   * passthrough events
   */
  void keyPressed(char key, int keyCode) {
    for(LevelLayer l: layers) {
      l.keyPressed(key, keyCode);
    }
  }

  void keyReleased(char key, int keyCode) {
    for(LevelLayer l: layers) {
      l.keyReleased(key, keyCode);
    }
  }

  void mouseMoved(int mx, int my) {
    for(LevelLayer l: layers) {
      l.mouseMoved(mx, my);
    }
  }

  void mousePressed(int mx, int my, int button) {
    for(LevelLayer l: layers) {
      l.mousePressed(mx, my, button);
    }
  }

  void mouseDragged(int mx, int my, int button) {
    for(LevelLayer l: layers) {
      l.mouseDragged(mx, my, button);
    }
  }

  void mouseReleased(int mx, int my, int button) {
    for(LevelLayer l: layers) {
      l.mouseReleased(mx, my, button);
    }
  }

  void mouseClicked(int mx, int my, int button) {
    for(LevelLayer l: layers) {
      l.mouseClicked(mx, my, button);
    }
  }
  
  // layer component show/hide methods
  void showBackground(boolean b)  { for(LevelLayer l: layers) { l.showBackground = b; }}
  void showBoundaries(boolean b)  { for(LevelLayer l: layers) { l.showBoundaries = b; }}
  void showPickups(boolean b)     { for(LevelLayer l: layers) { l.showPickups = b; }}
  void showDecals(boolean b)      { for(LevelLayer l: layers) { l.showDecals = b; }}
  void showInteractors(boolean b) { for(LevelLayer l: layers) { l.showInteractors = b; }}
  void showActors(boolean b)      { for(LevelLayer l: layers) { l.showActors = b; }}
  void showForeground(boolean b)  { for(LevelLayer l: layers) { l.showForeground = b; }}
  void showTriggers(boolean b)    { for(LevelLayer l: layers) { l.showTriggers = b; }}

}
