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
  void clearBoundaries() { boundaries.clear(); }

  // The list of static, non-interacting sprites, building up the background
  void addBackgroundSprite(Drawable fixed)    { fixed_background.add(fixed);    }
  void removeBackgroundSprite(Drawable fixed) { fixed_background.remove(fixed); }
  void clearBackground() { fixed_background.clear(); }

  // The list of static, non-interacting sprites, building up the foreground
  void addForegroundSprite(Drawable fixed)    { fixed_foreground.add(fixed);    }
  void removeForegroundSprite(Drawable fixed) { fixed_foreground.remove(fixed); }
  void clearForeground() { fixed_foreground.clear(); }

  // The list of decals (pure graphic visuals)
  void addDecal(Decal decal)    { decals.add(decal);    }
  void removeDecal(Decal decal) { decals.remove(decal); }
  void clearDecals() { decals.clear(); }

  // event triggers
  void addTrigger(Trigger trigger)    { triggers.add(trigger);    }
  void removeTrigger(Trigger trigger) { triggers.remove(trigger); }
  void clearTriggers() { triggers.clear(); }

  // The list of sprites that may only interact with the player(s) (and boundaries)
  void addForPlayerOnly(Pickup pickup) { pickups.add(pickup); bind(pickup); }
  void removeForPlayerOnly(Pickup pickup) { pickups.remove(pickup); }
  void clearPickups() { pickups.clear(); npcpickups.clear(); }

  // The list of sprites that may only interact with non-players(s) (and boundaries)
  void addForInteractorsOnly(Pickup pickup) { npcpickups.add(pickup); bind(pickup); }
  void removeForInteractorsOnly(Pickup pickup) { npcpickups.remove(pickup); }

  // The list of fully interacting non-player sprites
  void addInteractor(Interactor interactor) { interactors.add(interactor); bind(interactor); }
  void removeInteractor(Interactor interactor) { interactors.remove(interactor); }
  void clearInteractors() { interactors.clear(); bounded_interactors.clear(); }

  // The list of fully interacting non-player sprites that have associated boundaries
  void addBoundedInteractor(BoundedInteractor bounded_interactor) { bounded_interactors.add(bounded_interactor); bind(bounded_interactor); }
  void removeBoundedInteractor(BoundedInteractor bounded_interactor) { bounded_interactors.remove(bounded_interactor); }

  // The list of player sprites
  void addPlayer(Player player) { players.add(player); bind(player); }
  void removePlayer(Player player) { players.remove(player); }
  void clearPlayers() { players.clear(); }

  void updatePlayer(Player oldPlayer, Player newPlayer) {
    int pos = players.indexOf(oldPlayer);
    if (pos > -1) {
      players.set(pos, newPlayer);
      newPlayer.boundaries.clear();
      bind(newPlayer); }}


  // private actor binding
  void bind(Actor actor) { actor.setLevelLayer(this); }
  
  // clean up all transient things
  void cleanUp() {
    cleanUpActors(interactors);
    cleanUpActors(bounded_interactors);
    cleanUpActors(pickups);
    cleanUpActors(npcpickups);
  }
  
  // cleanup an array list
  void cleanUpActors(ArrayList<? extends Actor> list) {
    for(int a = list.size()-1; a>=0; a--) {
      if(!list.get(a).isPersistent()) {
        list.remove(a);
      }
    }
  }
  
  // clear everything except the player
  void clearExceptPlayer() {
    clearBoundaries();
    clearBackground();
    clearForeground();
    clearDecals();
    clearTriggers();
    clearPickups();
    clearInteractors();    
  }

  // clear everything
  void clear() {
    clearExceptPlayer();
    clearPlayers();
  }

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
    fixed_background = new ArrayList<Drawable>();
    fixed_foreground = new ArrayList<Drawable>();
    pickups = new ArrayList<Pickup>();
    npcpickups = new ArrayList<Pickup>();
    decals = new ArrayList<Decal>();
    interactors = new ArrayList<Interactor>();
    bounded_interactors = new ArrayList<BoundedInteractor>();
    players  = new ArrayList<Player>();
    triggers = new ArrayList<Trigger>();
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
    if(sx!=1) { width /= sx; width -= screenWidth; }
    if(sy!=1) { height /= sy; }
    nonstandard = (xScale!=1 || yScale!=1 || xTranslate!=0 || yTranslate!=0);
  }
  
  /**
   * Get the level this layer exists in
   */
  Level getLevel() {
    return parent;
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
   * map a screen coordinate to its layer coordinate equivalent.
   */
  float[] mapCoordinateFromScreen(float x, float y) {
    float mx = map(x/xScale,  0,viewbox.w,  viewbox.x,viewbox.x + viewbox.w);
    float my = map(y/yScale,  0,viewbox.h,  viewbox.y,viewbox.y + viewbox.h);    
    return new float[]{mx, my};
  }

  /**
   * map a layer coordinate to its screen coordinate equivalent.
   */
  float[] mapCoordinateToScreen(float x, float y) {
    float mx = (x/xScale - xTranslate);
    float my = (y/yScale - yTranslate);
    mx *= xScale;
    my *= yScale;
    return new float[]{mx, my};
  }

  /**
   * get the mouse pointer, as relative coordinates,
   * relative to the indicated x/y coordinate in the layer.
   */
  float[] getMouseInformation(float x, float y, float mouseX, float mouseY) {
    float[] mapped = mapCoordinateToScreen(x, y);
    float ax = mapped[0], ay = mapped[1];
    mapped = mapCoordinateFromScreen(mouseX, mouseY);
    float mx = mapped[0], my = mapped[1];
    float dx = mx-ax, dy = my-ay,
          len = sqrt(dx*dx + dy*dy);
    return new float[] {dx,dy,len};
  }

  /**
   * draw this level layer.
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
    
    // save applied transforms so far
    pushMatrix();
    // transform the layer coordinates
    translate(viewbox.x-x, viewbox.y-y);
    scale(xScale, yScale);
    // draw all layer components
    if (showBackground) { handleBackground(x,y,w,h); } else { debugfunctions_drawBackground((int)width, (int)height); }
    if (showBoundaries)   handleBoundaries(x,y,w,h);
    if (showPickups)      handlePickups(x,y,w,h);
    if (showInteractors)  handleNPCs(x,y,w,h);
    if (showActors)       handlePlayers(x,y,w,h);
    if (showDecals)       handleDecals(x,y,w,h);
    if (showForeground)   handleForeground(x,y,w,h);
    if (showTriggers)     handleTriggers(x,y,w,h);
    // restore saved transforms
    popMatrix();
  }

  /**
   * Background color/sprites
   */
  void handleBackground(float x, float y, float w, float h) { 
    if (backgroundColor != -1) {
      background(backgroundColor);
    }

    for(Drawable s: fixed_background) {
      s.draw(x,y,w,h);
    }
  }

  /**
   * Boundaries should normally not be drawn, but
   * a debug flag can make them get drawn anyway.
   */
  void handleBoundaries(float x, float y, float w, float h) { 
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

  /**
   * Handle both player and NPC Pickups.
   */
  void handlePickups(float x, float y, float w, float h) { 
    // player pickups
    for(int i = pickups.size()-1; i>=0; i--) {
      Pickup p = pickups.get(i);
      if(p.remove) {
        pickups.remove(i);
        continue; }

      // boundary interference?
      if(p.interacting && p.inMotion && !p.onlyplayerinteraction) {
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

    // ---- npc pickups
    for(int i = npcpickups.size()-1; i>=0; i--) {
      Pickup p = npcpickups.get(i);
      if(p.remove) {
        npcpickups.remove(i);
        continue; }

      // boundary interference?
      if(p.interacting && p.inMotion && !p.onlyplayerinteraction) {
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

  /**
   * Handle both regular and bounded NPCs
   */
  void handleNPCs(float x, float y, float w, float h) {
    handleNPCs(x, y, w, h, interactors);
    handleNPCs(x, y, w, h, bounded_interactors);
  }
  
  /**
   * helper function to prevent code duplication
   */
  void handleNPCs(float x, float y, float w, float h, ArrayList<? extends Interactor> interactors) {
    for(int i = 0; i<interactors.size(); i++) {
      Interactor a = interactors.get(i);
      if(a.remove) {
        interactors.remove(i);
        continue; }

      // boundary interference?
      if(a.interacting && a.inMotion && !a.onlyplayerinteraction) {
        for(Boundary b: boundaries) {
            CollisionDetection.interact(b,a); }
        // boundary interference from bounded interactors?
        for(BoundedInteractor o: bounded_interactors) {
          if(o == a) continue;
          if(o.bounding) {
            for(Boundary b: o.boundaries) {
                CollisionDetection.interact(b,a); }}}}

      // draw interactor
      a.draw(x,y,w,h);
    }
  }

  /**
   * Handle player characters
   */
  void handlePlayers(float x, float y, float w, float h) {
    for(int i=players.size()-1; i>=0; i--) {
      Player a = players.get(i);

      if(a.remove) {
        players.remove(i);
        continue; }

      if(a.interacting) {

        // boundary interference?
        if(a.inMotion) {
          for(Boundary b: boundaries) {
            CollisionDetection.interact(b,a); }

          // boundary interference from bounded interactors?
          for(BoundedInteractor o: bounded_interactors) {
            if(o.bounding) {
              for(Boundary b: o.boundaries) {
                CollisionDetection.interact(b,a); }}}}

        // collisions with other sprites?
        if(!a.isDisabled()) {
          handleActorCollision(x,y,w,h,a,interactors);
          handleActorCollision(x,y,w,h,a,bounded_interactors);
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
  
  /**
   * helper function to prevent code duplication
   */
  void handleActorCollision(float x, float y, float w, float h, Actor a, ArrayList<? extends Interactor> interactors) {
    for(int i = 0; i<interactors.size(); i++) {
      Actor o = interactors.get(i);
      if(!o.interacting) continue;
      float[] overlap = a.overlap(o);
      if(overlap!=null) {
        a.overlapOccurredWith(o, overlap);
        int len = overlap.length;
        float[] inverse = new float[len];
        arrayCopy(overlap,0,inverse,0,len);
        for(int pos=0; pos<len; pos++) { inverse[pos] = -inverse[pos]; }
        o.overlapOccurredWith(a, inverse); 
      }
      else if(o instanceof Tracker) {
        ((Tracker)o).track(a, x,y,w,h);
      }
    }
  }

  /**
   * Draw all decals.
   */
  void handleDecals(float x, float y, float w, float h) {
    for(int i=decals.size()-1; i>=0; i--) {
      Decal d = decals.get(i);
      if(d.remove) { decals.remove(i); continue; }
      d.draw(x,y,w,h);
    }
  }

  /**
   * Draw all foreground sprites
   */
  void handleForeground(float x, float y, float w, float h) {
    for(Drawable s: fixed_foreground) {
      s.draw(x,y,w,h);
    }
  }

  /**
   * Triggers should normally not be drawn, but
   * a debug flag can make them get drawn anyway.
   */
  void handleTriggers(float x, float y, float w, float h) {
    for(Drawable t: triggers) {
      t.draw(x,y,w,h);
    }
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
