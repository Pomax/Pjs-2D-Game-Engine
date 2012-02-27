/**
 * This class defines a generic sprite engine level.
 * It has the following components:
 *
 *  - background sprite layer
 *  - (actor blocking) boundaries
 *  - pickup 'actors'
 *  - non-player actors
 *  - player actors
 *  - foreground sprite layer
 *
 */
class Level {
  // debug flags, very good for finding out what's going on.
  boolean debug = true,
          showBackground = true,
          showBoundaries = true,
          showPickups = true,
          showInteractors = true,
          showActors = true,
          showForeground = true;

  class ViewBox { float x=0, y=0, w=0, h=0; }

  // the list of "standable" regions
  ArrayList<Boundary> boundaries = new ArrayList<Boundary>();
  void addBoundary(Boundary boundary) { boundaries.add(boundary); }

  // The list of static, non-interacting sprites, building up the background
  ArrayList<Positionable> fixed_background = new ArrayList<Positionable>();
  void addStaticSpriteBG(Positionable fixed) { this.fixed_background.add(fixed); }

  // The list of static, non-interacting sprites, building up the foreground
  ArrayList<Positionable> fixed_foreground = new ArrayList<Positionable>();
  void addStaticSpriteFG(Positionable fixed) { this.fixed_foreground.add(fixed); }

  // The list of sprites that may only interact with the player(s) (and boundaries)
  ArrayList<Pickup> pickups = new ArrayList<Pickup>();
  void addForPlayerOnly(Pickup pickup) { pickups.add(pickup); }

  // The list of fully interacting non-player sprites
  ArrayList<Interactor> interactors = new ArrayList<Interactor>();
  void addInteractor(Interactor interactor) { interactors.add(interactor); }

  // The list of player sprites
  ArrayList<Player> players  = new ArrayList<Player>();
  void addPlayer(Player player) { players.add(player); }


  // level dimensions
  float width, height;

  // current viewbox
  ViewBox viewbox = new ViewBox();

  /**
   * Levels have dimensions!
   */
  Level(float _width, float _height) { width = _width; height = _height; }

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

  /**
   * Select all boundaries that are visible.
   */
  ArrayList<Boundary> getBoundaries() {
    // TODO: coordinate-based selection goes here
    return boundaries;
  }

  /**
   * Select all non-player static sprites that are visible.
   */
  ArrayList<Positionable> getStaticSpritesBG() {
    // TODO: coordinate-based selection goes here
    return fixed_background;
  }

  /**
   * Select all non-player static sprites that are visible.
   */
  ArrayList<Positionable> getStaticSpritesFG() {
    // TODO: coordinate-based selection goes here
    return fixed_foreground;
  }

  /**
   * Select all non-player static sprites that are visible.
   */
  ArrayList<Pickup> getForPlayerOnlies() {
    // TODO: coordinate-based selection goes here
    return pickups;
  }

  /**
   * Select all non-player static sprites that are visible.
   */
  ArrayList<Interactor> getInteractors() {
    // TODO: coordinate-based selection goes here
    return interactors;
  }

  /**
   * Select all non-player static sprites that are visible.
   */
  ArrayList<Player> getPlayers() {
    // TODO: coordinate-based selection goes here
    return players;
  }

  /**
   * draw the leve, as seen from the viewbox
   */
  void draw() {
    // local overrides
    ArrayList<Boundary> boundaries = getBoundaries();
    ArrayList<Positionable> fixed_background = getStaticSpritesBG();
    ArrayList<Pickup> pickups = getForPlayerOnlies();
    ArrayList<Interactor> interactors = getInteractors();
    ArrayList<Player> players = getPlayers();
    ArrayList<Positionable> fixed_foreground = getStaticSpritesFG();

    // fixed background sprites
    if(showBackground) {
      for(Positionable s: fixed_background) {
        s.draw();
      }
    } else {
      drawBackground();
    }

    // boundaries
    if(showBoundaries) {
      for(Boundary b: boundaries) {
        b.draw();
      }
    }

    // pickups
    if(showPickups) {
      for(Pickup p: pickups) {
        // boundary interference?
        if(p.interacting) {
          for(Boundary b: getBoundaries()) {
            if(p.boundary==null) {
              interact(b,p); }}}
        // player interaction?
        for(Player a: players) {
          if(!a.interacting) continue;
          float[] overlap = a.overlap(p);
          if(overlap!=null) {
            p.overlapOccuredWith(a); }}
        // draw pickup
        p.draw();
      }
    }

    // non-player actors
    if(showInteractors) {
      for(int i = interactors.size()-1; i>=0; i--) {
        Interactor a = interactors.get(i);
        if(a.remove) { interactors.remove(i); continue; }
        // boundary interference?
        if(a.interacting) {
          for(Boundary b: getBoundaries()) {
            if(a.boundary==null) {
              interact(b,a); }}}
        // draw interactor
        a.draw();
      }
    }

    // player actors
    if(showActors) {
      for(int i=players.size()-1; i>=0; i--) {
        Player a = players.get(i);
        if(a.remove) { players.remove(i); continue; }
        if(a.interacting) {
          // boundary interference?
          for(Boundary b: boundaries) {
            if(a.boundary==null) {
              interact(b,a); }}

          // collisions with other sprites?
          for(Actor o: interactors) {
            if(!o.interacting) continue;
            float[] overlap = a.overlap(o);
            if(overlap!=null) {
              a.overlapOccuredWith(o, overlap);
              o.overlapOccuredWith(a, new float[]{-overlap[0], -overlap[1], overlap[2]}); }}}
        // draw actor
        a.draw();
      }
    }

    // fixed background sprites
    if(showForeground) {
      for(Positionable s: fixed_foreground) {
        s.draw();
      }
    }
  }

  /**
   * Perform actor/boundary collision detection
   */
  void interact(Boundary b, Actor a) {
    float[] intersection = b.blocks(a);
    if(intersection!=null) {
      a.stop(intersection[0], intersection[1]);
      a.attachTo(b);
    }
  }

  /**
   * passthrough event
   */
  void keyPressed(char key, int keyCode) {
    if(debug) {
      if(key=='1') { showBackground = !showBackground; }
      if(key=='2') { showBoundaries = !showBoundaries; }
      if(key=='3') { showPickups = !showPickups; }
      if(key=='4') { showInteractors = !showInteractors; }
      if(key=='5') { showActors = !showActors; }
      if(key=='6') { showForeground = !showForeground; }
      if(key=='7') {       
        for(Pickup p: pickups) { p.debug = !p.debug; }
        for(Interactor i: interactors) { i.debug = !i.debug; }
        for(Player p: players) { p.debug = !p.debug; }
      }
    }
    for(Player a: players) {
      a.keyPressed(key,keyCode); }}

  /**
   * passthrough event
   */
  void keyReleased(char key, int keyCode) {
    for(Player a: players) {
      a.keyReleased(key,keyCode); }}

  void mouseMoved(int mx, int my) {}
  void mousePressed(int mx, int my) {}
  void mouseDragged(int mx, int my) {}
  void mouseReleased(int mx, int my) {}
  void mouseClicked(int mx, int my) {}
}
