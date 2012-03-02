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
abstract class Level {
  // debug flags, very good for finding out what's going on.
  boolean debug = true,
          showBackground = true,
          showBoundaries = true,
          showPickups = true,
          showInteractors = true,
          showActors = true,
          showForeground = true,
          showTriggers = false;
  
  boolean finished  = false;
  boolean swappable = false;
  color backgroundColor = color(127,127,127);

  class ViewBox { float x=0, y=0, w=0, h=0; }

  // the list of "standable" regions
  ArrayList<Boundary> boundaries = new ArrayList<Boundary>();
  void addBoundary(Boundary boundary) { boundaries.add(boundary); }

  // The list of static, non-interacting sprites, building up the background
  ArrayList<Drawable> fixed_background = new ArrayList<Drawable>();
  void addStaticSpriteBG(Drawable fixed) { this.fixed_background.add(fixed); }

  // The list of static, non-interacting sprites, building up the foreground
  ArrayList<Drawable> fixed_foreground = new ArrayList<Drawable>();
  void addStaticSpriteFG(Drawable fixed) { this.fixed_foreground.add(fixed); }

  // The list of sprites that may only interact with the player(s) (and boundaries)
  ArrayList<Pickup> pickups = new ArrayList<Pickup>();
  void addForPlayerOnly(Pickup pickup) { pickups.add(pickup); }

  // The list of fully interacting non-player sprites
  ArrayList<Interactor> interactors = new ArrayList<Interactor>();
  void addInteractor(Interactor interactor) { interactors.add(interactor); }

  // The list of fully interacting non-player sprites that have associated boundaries
  ArrayList<BoundedInteractor> bounded_interactors = new ArrayList<BoundedInteractor>();
  void addBoundedInteractor(BoundedInteractor bounded_interactor) { bounded_interactors.add(bounded_interactor); }

  // The list of player sprites
  ArrayList<Player> players  = new ArrayList<Player>();
  void addPlayer(Player player) { players.add(player); }

  // event triggers
  ArrayList<Trigger> triggers = new ArrayList<Trigger>();
  void addTrigger(Trigger trigger) { triggers.add(trigger); }


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
   * draw the leve, as seen from the viewbox
   */
  void draw() {
    // draw fallback color
    background(backgroundColor);

    // viewbox
    translate(-viewbox.x, -viewbox.y);

    // fixed background sprites
    if(showBackground) {
      for(Drawable s: fixed_background) {
        s.draw(viewbox.x, viewbox.y, viewbox.w, viewbox.h);
      }
    } else {
      drawBackground((int)width, (int)height);
    }

    // boundaries
    if(showBoundaries) {
      // regular boundaries
      for(Boundary b: boundaries) {
        b.draw(viewbox.x, viewbox.y, viewbox.w, viewbox.h);
      }
      // bounded interactor boundaries
      for(BoundedInteractor b: bounded_interactors) {
        if(b.bounding) {
          b.drawBoundaries(viewbox.x, viewbox.y, viewbox.w, viewbox.h);
        }
      }
    }

    // pickups
    if(showPickups) {
      for(int i = pickups.size()-1; i>=0; i--) {
        Pickup p = pickups.get(i);
        if(p.remove) { pickups.remove(i); continue; }
        // boundary interference?
        if(p.interacting) {
          for(Boundary b: boundaries) {
            if(p.boundary==null) {
              interact(b,p); }}
          for(BoundedInteractor o: bounded_interactors) {
            if(o.bounding) {
              for(Boundary b: o.boundaries) {
                if(p.boundary==null) {
                  interact(b,p); }}}}}
        // player interaction?
        for(Player a: players) {
          if(!a.interacting) continue;
          float[] overlap = a.overlap(p);
          if(overlap!=null) {
            p.overlapOccuredWith(a); }}
        // draw pickup
        p.draw(viewbox.x, viewbox.y, viewbox.w, viewbox.h);
      }
    }

    // non-player actors
    if(showInteractors) {
      for(int i = interactors.size()-1; i>=0; i--) {
        Interactor a = interactors.get(i);
        if(a.remove) { interactors.remove(i); continue; }
        // boundary interference?
        if(a.interacting) {
          for(Boundary b: boundaries) {
            if(a.boundary==null) {
              interact(b,a); }}
          // boundary interference from bounded interactors?
          for(BoundedInteractor o: bounded_interactors) {
            if(o.bounding) {
              for(Boundary b: o.boundaries) {
                if(a.boundary==null) {
                  interact(b,a); }}}}}
        // draw interactor
        a.draw(viewbox.x, viewbox.y, viewbox.w, viewbox.h);
      }

      // FIXME: code duplication, since it's the same as for regular interactors.
      for(int i = bounded_interactors.size()-1; i>=0; i--) {
        Interactor a = bounded_interactors.get(i);
        if(a.remove) { bounded_interactors.remove(i); continue; }
        // boundary interference?
        if(a.interacting) {
          for(Boundary b: boundaries) {
            if(a.boundary==null) {
              interact(b,a); }}}
        // draw interactor
        a.draw(viewbox.x, viewbox.y, viewbox.w, viewbox.h);
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

          // boundary interference from bounded interactors?
          for(BoundedInteractor o: bounded_interactors) {
            if(o.bounding) {
              for(Boundary b: o.boundaries) {
                if(a.boundary==null) {
                  interact(b,a); }}}}

          // collisions with other sprites?
          if(!a.isDisabled()) {
            for(Actor o: interactors) {
              if(!o.interacting) continue;
              float[] overlap = a.overlap(o);
              if(overlap!=null) {
                a.overlapOccuredWith(o, overlap);
                o.overlapOccuredWith(a, new float[]{-overlap[0], -overlap[1], overlap[2]}); }}

            // FIXME: code duplication, since it's the same as for regular interactors.
            for(Actor o: bounded_interactors) {
              if(!o.interacting) continue;
              float[] overlap = a.overlap(o);
              if(overlap!=null) {
                a.overlapOccuredWith(o, overlap);
                o.overlapOccuredWith(a, new float[]{-overlap[0], -overlap[1], overlap[2]}); }}
          }

          // has the player tripped any triggers?
          for(int j = triggers.size()-1; j>=0; j--) {
            Trigger t = triggers.get(j);
            if(t.remove) { triggers.remove(t); continue; }
            float[] overlap = t.overlap(a);
            if(overlap==null && t.disabled) { t.enable(); }
            else if(overlap!=null && !t.disabled) { t.run(this, overlap); }}
        }

        // draw actor
        a.draw(viewbox.x, viewbox.y, viewbox.w, viewbox.h);
      }
    }

    // fixed background sprites
    if(showForeground) {
      for(Drawable s: fixed_foreground) {
        s.draw(viewbox.x, viewbox.y, viewbox.w, viewbox.h);
      }
    }
    
    if(showTriggers) {
      for(Drawable t: triggers) {
        t.draw(viewbox.x, viewbox.y, viewbox.w, viewbox.h);
      }
    }
  }

  /**
   * Perform actor/boundary collision detection
   */
  void interact(Boundary b, Actor a) {
    float[] intersection = b.blocks(a);
    if(intersection!=null) {
      float ix=a.ix, iy=a.iy;
      a.stop(intersection[0], intersection[1]);
      a.attachTo(b);
      a.addImpulse(ix,iy);
      a.update();
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
      if(key=='7') { showTriggers = !showTriggers; }
      if(key=='8') {
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
