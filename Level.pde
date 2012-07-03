/**
 * This class defines a generic sprite engine level.
 * A layer may consist of one or more layers, with
 * each layer modeling a 'self-contained' slice.
 * For top-down games, these slices yield pseudo-height,
 * whereas for side-view games they yield pseudo-depth.
 */
abstract class Level extends Screen {
  boolean finished  = false;

  ArrayList<LevelLayer> layers;
  HashMap<String, Integer> layerids;

  // current viewbox
  ViewBox viewbox;

  /**
   * Levels have dimensions!
   */
  Level(float _width, float _height) {
    super(_width,_height);
    layers = new ArrayList<LevelLayer>();
    layerids = new HashMap<String, Integer>();
    viewbox = new ViewBox(_width, _height);
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
  
  void cleanUp() {
    for(LevelLayer l: layers) {
      l.cleanUp();
    }
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
  void finish() { setSwappable(); finished = true; }

  /**
   * What to do on a premature level finish (for instance, a reset-warranting death)
   */
  void end() { finish(); }

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
