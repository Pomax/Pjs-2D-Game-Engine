/**
 * Level layers are intended to regulate both interaction
 * (actors on one level cannot affect actors on another)
 * as well as to effect pseudo-depth.
 *
 * Every layer may contain the following components,
 * drawn in the order listed:
 *
 *  - a background sprite layer
 *  - (actor blocking) boundaries
 *  - pickups (extensions on actors)
 *  - non-players (extensions on actors)
 *  - player actors (extension on actors)
 *  - a foreground sprite layer
 *
 */
abstract class LevelLayer {
  // debug flags, very good for finding out what's going on.
  boolean debug = true,
          showBackground = true,
          showBoundaries = false,
          showPickups = true,
          showDecals = true,
          showInteractors = true,
          showActors = true,
          showForeground = true,
          showTriggers = false;

  // The various layer components
  ArrayList<Boundary> boundaries;
  ArrayList<Drawable> fixed_background, fixed_foreground;
  ArrayList<Pickup> pickups;
  ArrayList<Pickup> npcpickups;
  ArrayList<Decal> decals;
  ArrayList<Interactor> interactors;
  ArrayList<BoundedInteractor> bounded_interactors;
  ArrayList<Player> players;
  ArrayList<Trigger> triggers;

  // Level layers need not share the same coordinate system
  // as the managing level. For instance, things in the
  // background might be rendered smaller to seem farther
  // away, or larger, to create an exxagerated look.
  float xTranslate = 0,
         yTranslate = 0,
         xScale = 1,
         yScale = 1;
   boolean nonstandard = false;

  // Fallback color if a layer has no background color.
  // By default, this color is 100% transparent black.
  color backgroundColor = -1;
  void setBackgroundColor(color c) {
    backgroundColor = c;
  }

  // the list of "collision" regions
  void addBoundary(Boundary boundary)    { boundaries.add(boundary);    }
  void removeBoundary(Boundary boundary) { boundaries.remove(boundary); }

  // The list of static, non-interacting sprites, building up the background
  void addStaticSpriteBG(Drawable fixed)    { fixed_background.add(fixed);    }
  void removeStaticSpriteBG(Drawable fixed) { fixed_background.remove(fixed); }

  // The list of static, non-interacting sprites, building up the foreground
  void addStaticSpriteFG(Drawable fixed)    { fixed_foreground.add(fixed);    }
  void removeStaticSpriteFG(Drawable fixed) { fixed_foreground.remove(fixed); }

  // The list of decals (pure graphic visuals)
  void addDecal(Decal decal)    { decals.add(decal);   }
  void removeDecal(Decal decal) { decals.remove(decal); }

  // event triggers
  void addTrigger(Trigger trigger)    { triggers.add(trigger);    }
  void removeTrigger(Trigger trigger) { triggers.remove(trigger); }


  // The list of sprites that may only interact with the player(s) (and boundaries)
  void addForPlayerOnly(Pickup pickup) {
    pickups.add(pickup);
    bind(pickup);
    if(javascript!=null) { javascript.addActor(); }}

  void removeForPlayerOnly(Pickup pickup) {
    pickups.remove(pickup);
    if(javascript!=null) { javascript.removeActor(); }}

  // The list of sprites that may only interact with non-players(s) (and boundaries)
  void addForInteractorsOnly(Pickup pickup) {
    npcpickups.add(pickup);
    bind(pickup);
    if(javascript!=null) { javascript.addActor(); }}

  void removeForInteractorsOnly(Pickup pickup) {
    npcpickups.remove(pickup);
    if(javascript!=null) { javascript.removeActor(); }}

  // The list of fully interacting non-player sprites
  void addInteractor(Interactor interactor) {
    interactors.add(interactor);
    bind(interactor);
    if(javascript!=null) { javascript.addActor(); }}

  void removeInteractor(Interactor interactor) {
    interactors.remove(interactor);
    if(javascript!=null) { javascript.removeActor(); }}

  // The list of fully interacting non-player sprites that have associated boundaries
  void addBoundedInteractor(BoundedInteractor bounded_interactor) {
    bounded_interactors.add(bounded_interactor);
    bind(bounded_interactor);
    if(javascript!=null) { javascript.addActor(); }}

  void removeBoundedInteractor(BoundedInteractor bounded_interactor) {
    bounded_interactors.remove(bounded_interactor);
    if(javascript!=null) { javascript.removeActor(); }}

  // The list of player sprites
  void addPlayer(Player player) {
    players.add(player);
    bind(player);
    if(javascript!=null) { javascript.addActor(); }}

  void removePlayer(Player player) {
    players.remove(player);
    if(javascript!=null) { javascript.removeActor(); }}

  void updatePlayer(Player oldPlayer, Player newPlayer) {
    int pos = players.indexOf(oldPlayer);
    if (pos > -1) { 
      players.set(pos, newPlayer);
      bind(newPlayer); }}


  // private actor binding
  void bind(Actor actor) { actor.setLevelLayer(this); }

  // =============================== //
  //   MAIN CLASS CODE STARTS HERE   //
  // =============================== //
  
  // level layer size
  float width=0, height=0;
  
  // the owning level for this layer
  Level parent;
  
  // level viewbox
  ViewBox viewbox;
  
  /**
   * fallthrough constructor
   */
  LevelLayer(Level p) {
    this(p, p.width, p.height);
  }

  /**
   * Constructor
   */
  LevelLayer(Level p, float w, float h) {
    this.parent = p;
    this.viewbox = p.viewbox;
    this.width = w;
    this.height = h;
    
    boundaries = new ArrayList<Boundary>();
    Computer.arraylists("Boundary");
    fixed_background = new ArrayList<Drawable>();
    Computer.arraylists("Drawable");
    fixed_foreground = new ArrayList<Drawable>();
    Computer.arraylists("Drawable");
    pickups = new ArrayList<Pickup>();
    Computer.arraylists("Pickup");
    npcpickups = new ArrayList<Pickup>();
    Computer.arraylists("Pickup");
    decals = new ArrayList<Decal>();
    Computer.arraylists("Decal");
    interactors = new ArrayList<Interactor>();
    Computer.arraylists("Interactor");
    bounded_interactors = new ArrayList<BoundedInteractor>();
    Computer.arraylists("BoundedInteractor");
    players  = new ArrayList<Player>();
    Computer.arraylists("Player");
    triggers = new ArrayList<Trigger>();
    Computer.arraylists("Trigger");
  }

  /**
   * More specific constructor with offset/scale values indicated
   */
  LevelLayer(Level p, float w, float h, float ox, float oy, float sx, float sy) {
    this(p,w,h);
    xTranslate = ox;
    yTranslate = oy;
    xScale = sx;
    yScale = sy;
    nonstandard = (xScale!=1 || yScale!=1 || xTranslate!=0 || yTranslate!=0);
  }

  // used for statistics
  int getActorCount() {
    return players.size() + bounded_interactors.size() + interactors.size() + pickups.size();
  }

  /**
   * map a "normal" coordinate to this level's
   * coordinate system.
   */
  float[] mapCoordinate(float x, float y) {
    float vx = (x + xTranslate)*xScale,
          vy = (y + yTranslate)*yScale;
    return new float[]{vx, vy};
  }
  
  /**
   * map a layer coordinate to "normal"
   */
  float[] mapCoordinateFromScreen(float x, float y) {
    float mx = map(x/xScale,  0,viewbox.w,  viewbox.x,viewbox.x + viewbox.w);
    float my = map(y/yScale,  0,viewbox.h,  viewbox.y,viewbox.y + viewbox.h);    
    return new float[]{mx, my};
  }

  /**
   * map a layer coordinate to "normal"
   */
  float[] mapCoordinateToScreen(float x, float y) {
    float mx = (x/xScale - xTranslate);
    float my = (y/yScale - yTranslate);
    mx *= xScale;
    my *= yScale;
    return new float[]{mx, my};
  }

  /**
   *
   */
  void draw() {
    // get the level viewbox and tranform its
    // reference coordinate values.
    float x,y,w,h;
    float[] mapped = mapCoordinate(viewbox.x,viewbox.y);
    x = mapped[0];
    y = mapped[1];
    w = viewbox.w / xScale;
    h = viewbox.h / yScale;
    
    pushMatrix();

    // remember to transform the layer coordinates accordingly
    translate(viewbox.x-x, viewbox.y-y);
    scale(xScale, yScale);

// ----  draw fallback color
    if (backgroundColor != -1) {
      background(backgroundColor);
    }

// ---- fixed background sprites
    if(showBackground) {
      for(Drawable s: fixed_background) {
        s.draw(x,y,w,h);
      }
    } else {
      debugfunctions_drawBackground((int)width, (int)height);
    }

// ---- boundaries
    if(showBoundaries) {
      // regular boundaries
      for(Boundary b: boundaries) {
        b.draw(x,y,w,h);
      }
      // bounded interactor boundaries
      for(BoundedInteractor b: bounded_interactors) {
        if(b.bounding) {
          b.drawBoundaries(x,y,w,h);
        }
      }
    }

// ---- pickups
    if(showPickups) {
      for(int i = pickups.size()-1; i>=0; i--) {
        Pickup p = pickups.get(i);
        if(p.remove) {
          pickups.remove(i);
          if(javascript!=null) { javascript.removeActor(); }
          continue; }

        // boundary interference?
        if(p.interacting && !p.onlyplayerinteraction) {
          for(Boundary b: boundaries) {
            CollisionDetection.interact(b,p); }
          for(BoundedInteractor o: bounded_interactors) {
            if(o.bounding) {
              for(Boundary b: o.boundaries) {
                  CollisionDetection.interact(b,p); }}}}

        // player interaction?
        for(Player a: players) {
          if(!a.interacting) continue;
          float[] overlap = a.overlap(p);
          if(overlap!=null) {
            p.overlapOccurredWith(a);
            break; }}

        // draw pickup
        p.draw(x,y,w,h);
      }
    }


// ---- npc pickups
    if(showPickups) {
      for(int i = npcpickups.size()-1; i>=0; i--) {
        Pickup p = npcpickups.get(i);
        if(p.remove) {
          npcpickups.remove(i);
          if(javascript!=null) { javascript.removeActor(); }
          continue; }

        // boundary interference?
        if(p.interacting && !p.onlyplayerinteraction) {
          for(Boundary b: boundaries) {
            CollisionDetection.interact(b,p); }
          for(BoundedInteractor o: bounded_interactors) {
            if(o.bounding) {
              for(Boundary b: o.boundaries) {
                  CollisionDetection.interact(b,p); }}}}

        // npc interaction?
        for(Interactor a: interactors) {
          if(!a.interacting) continue;
          float[] overlap = a.overlap(p);
          if(overlap!=null) {
            p.overlapOccurredWith(a);
            break; }}

        // draw pickup
        p.draw(x,y,w,h);
      }
    }

// ----  non-player actors
    if(showInteractors) {
      for(int i = interactors.size()-1; i>=0; i--) {
        Interactor a = interactors.get(i);
        if(a.remove) {
          interactors.remove(i);
          if(javascript!=null) { javascript.removeActor(); }
          continue; }

        // boundary interference?
        if(a.interacting && !a.onlyplayerinteraction) {
          for(Boundary b: boundaries) {
              CollisionDetection.interact(b,a); }
          // boundary interference from bounded interactors?
          for(BoundedInteractor o: bounded_interactors) {
            if(o.bounding) {
              for(Boundary b: o.boundaries) {
                  CollisionDetection.interact(b,a); }}}}

        // draw interactor
        a.draw(x,y,w,h);
      }

      // FIXME: code duplication, since it's the same as for regular interactors.
      for(int i = bounded_interactors.size()-1; i>=0; i--) {
        Interactor a = bounded_interactors.get(i);
        if(a.remove) {
          bounded_interactors.remove(i);
          if(javascript!=null) { javascript.removeActor(); }
          continue; }
        // boundary interference?
        if(a.interacting && !a.onlyplayerinteraction) {
          for(Boundary b: boundaries) {
              CollisionDetection.interact(b,a); }}
        // draw interactor
        a.draw(x,y,w,h);
      }
    }
    
// ---- player actors
    if(showActors) {
      for(int i=players.size()-1; i>=0; i--) {
        Player a = players.get(i);
        if(a.remove) {
          players.remove(i);
          if(javascript!=null) { javascript.removeActor(); }
          continue; }
        if(a.interacting) {

          // boundary interference?
          for(Boundary b: boundaries) {
            CollisionDetection.interact(b,a); }

          // boundary interference from bounded interactors?
          for(BoundedInteractor o: bounded_interactors) {
            if(o.bounding) {
              for(Boundary b: o.boundaries) {
                CollisionDetection.interact(b,a); }}}

          // collisions with other sprites?
          if(!a.isDisabled()) {
            for(Actor o: interactors) {
              if(!o.interacting) continue;
              float[] overlap = a.overlap(o);
              if(overlap!=null) {
                a.overlapOccurredWith(o, overlap);
                o.overlapOccurredWith(a, new float[]{-overlap[0], -overlap[1], overlap[2]}); }
              else if(o instanceof Tracker) {
                ((Tracker)o).track(a, x,y,w,h);
              }
            }

            // FIXME: code duplication, since it's the same as for regular interactors.
            for(Actor o: bounded_interactors) {
              if(!o.interacting) continue;
              float[] overlap = a.overlap(o);
              if(overlap!=null) {
                a.overlapOccurredWith(o, overlap);
                o.overlapOccurredWith(a, new float[]{-overlap[0], -overlap[1], overlap[2]}); }
              else if(o instanceof Tracker) {
                ((Tracker)o).track(a, x,y,w,h);
              }
            }
          }

          // has the player tripped any triggers?
          for(int j = triggers.size()-1; j>=0; j--) {
            Trigger t = triggers.get(j);
            if(t.remove) { triggers.remove(t); continue; }
            float[] overlap = t.overlap(a);
            if(overlap==null && t.disabled) {
              t.enable(); 
            }
            else if(overlap!=null && !t.disabled) {
              t.run(this, a, overlap); 
            }
          }
        }

        // draw actor
        a.draw(x,y,w,h);
      }
    }

// ---- decals
    if(showDecals) {
      for(int i=decals.size()-1; i>=0; i--) {
        Decal d = decals.get(i);
        if(d.remove) { decals.remove(i); continue; }
        d.draw(x,y,w,h);
      }
    }

// ---- fixed foreground sprites
    if(showForeground) {
      for(Drawable s: fixed_foreground) {
        s.draw(x,y,w,h);
      }
    }

// ---- triggerable regions
    if(showTriggers) {
      for(Drawable t: triggers) {
        t.draw(x,y,w,h);
      }
    }

    popMatrix();
  }

  /**
   * passthrough events
   */
  void keyPressed(char key, int keyCode) {
    for(Player a: players) {
      a.keyPressed(key,keyCode); }}

  void keyReleased(char key, int keyCode) {
    for(Player a: players) {
      a.keyReleased(key,keyCode); }}

  void mouseMoved(int mx, int my) {
    for(Player a: players) {
      a.mouseMoved(mx,my); }}

  void mousePressed(int mx, int my, int button) {
    for(Player a: players) {
      a.mousePressed(mx,my,button); }}

  void mouseDragged(int mx, int my, int button) {
    for(Player a: players) {
      a.mouseDragged(mx,my,button); }}

  void mouseReleased(int mx, int my, int button) {
    for(Player a: players) {
      a.mouseReleased(mx,my,button); }}

  void mouseClicked(int mx, int my, int button) {
    for(Player a: players) {
      a.mouseClicked(mx,my,button); }}
}
