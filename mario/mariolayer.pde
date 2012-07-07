class MarioLayer extends LevelLayer {
  
  // constructor
  MarioLayer(Level owner) {
    this(owner, owner.width, owner.height, 0,0,1,1);
  }
  
  MarioLayer(Level owner, float w, float h, float ox, float oy, float sx, float sy) {
    super(owner,w,h,ox,oy,sx,sy);
    //showBoundaries = true;
    showTriggers = true;
  }
  
  /**
   * Add some ground.
   */
  void addGround(String tileset, float x1, float y1, float x2, float y2) {
    TilingSprite groundline = new TilingSprite(new Sprite("graphics/backgrounds/"+tileset+"-top.gif"), x1,y1,x2,y1+16);
    addStaticSpriteBG(groundline);
    TilingSprite groundfiller = new TilingSprite(new Sprite("graphics/backgrounds/"+tileset+"-filler.gif"), x1,y1+16,x2,y2);
    addStaticSpriteBG(groundfiller);
    addBoundary(new Boundary(x1,y1,x2,y1));
  }
  
  /**
   * Add some upside down ground
   */
  void addUpsideDownGround(String tileset, float x1, float y1, float x2, float y2) {
    TilingSprite groundfiller = new TilingSprite(new Sprite("graphics/backgrounds/"+tileset+"-filler.gif"), x1,y1,x2,y2-16);
    addStaticSpriteBG(groundfiller);
    Sprite topLayer = new Sprite("graphics/backgrounds/"+tileset+"-top.gif");
    topLayer.flipVertical();
    topLayer.flipHorizontal();
    TilingSprite groundline = new TilingSprite(topLayer, x1,y2-16,x2,y2);
    addStaticSpriteBG(groundline);
    addBoundary(new Boundary(x2,y2,x1,y2));
  }

  /**
   * This creates the raised, angled sticking-out-ground bit.
   * it's actually a sprite, not a rotated generated bit of ground.
   */
  void addSlant(float x, float y) {
    Sprite groundslant = new Sprite("graphics/backgrounds/ground-slant.gif");
    groundslant.align(LEFT, BOTTOM);
    groundslant.setPosition(x, y);
    addStaticSpriteBG(groundslant);
    addBoundary(new Boundary(x, y + 48 - groundslant.height, x + 48, y - groundslant.height));
  }

  // add some mario-style bushes
  void addBushes() {
    // one bush, composed of four segmetns (sprites 1, 3, 4 and 5)
    int[] bush = {
      1, 3, 4, 5
    };
    for (int i=0, xpos=0, end=bush.length; i<end; i++) {
      Sprite sprite = new Sprite("graphics/backgrounds/bush-0"+bush[i]+".gif");
      xpos += sprite.width;
      sprite.align(CENTER, BOTTOM);
      sprite.setPosition(116 + xpos, height-48);
      addStaticSpriteFG(sprite);
    }

    // two bush, composed of eight segments
    bush = new int[] {
      1, 2, 4, 2, 3, 4, 2, 5
    };
    for (int i=0, xpos=0, end=bush.length; i<end; i++) {
      Sprite sprite = new Sprite("graphics/backgrounds/bush-0"+bush[i]+".gif");
      xpos += sprite.width;
      sprite.align(CENTER, BOTTOM);
      sprite.setPosition(384 + xpos, height-48);
      addStaticSpriteFG(sprite);
    }

    // three bush
    bush = new int[] {
      1, 3, 4, 5
    };
    for (int i=0, xpos=0, end=bush.length; i<end; i++) {
      Sprite sprite = new Sprite("graphics/backgrounds/bush-0"+bush[i]+".gif");
      xpos += sprite.width;
      sprite.align(CENTER, BOTTOM);
      sprite.setPosition(868 + xpos, height-48);
      addStaticSpriteFG(sprite);
    }

    // four bush
    bush = new int[] {
      1, 2, 4, 3, 4, 5
    };
    for (int i=0, xpos=0, end=bush.length; i<end; i++) {
      Sprite sprite = new Sprite("graphics/backgrounds/bush-0"+bush[i]+".gif");
      xpos += sprite.width;
      sprite.align(CENTER, BOTTOM);
      sprite.setPosition(1344 + xpos, height-48);
      addStaticSpriteFG(sprite);
    }
  }

  /**
   * Add a platform with solid ground underneath.
   */
  void addGroundPlatform(String tileset, float x, float y, float w, float h) {
    // top layer
    Sprite lc = new Sprite("graphics/backgrounds/"+tileset+"-corner-left.gif");
    lc.align(LEFT, TOP);
    lc.setPosition(x, y);
    Sprite tp = new Sprite("graphics/backgrounds/"+tileset+"-top.gif");
    Sprite rc = new Sprite("graphics/backgrounds/"+tileset+"-corner-right.gif");
    rc.align(LEFT, TOP);
    rc.setPosition(x+w-rc.width, y);
    TilingSprite toprow = new TilingSprite(tp, x+lc.width, y, x+(w-rc.width), y+tp.height);

    addStaticSpriteBG(lc);
    addStaticSpriteBG(toprow);
    addStaticSpriteBG(rc);

    // sides/filler
    TilingSprite sideleft  = new TilingSprite(new Sprite("graphics/backgrounds/"+tileset+"-side-left.gif"),  x,            y+tp.height, x+lc.width,     y+h);
    TilingSprite filler    = new TilingSprite(new Sprite("graphics/backgrounds/"+tileset+"-filler.gif"),     x+lc.width,   y+tp.height, x+(w-rc.width), y+h);
    TilingSprite sideright = new TilingSprite(new Sprite("graphics/backgrounds/"+tileset+"-side-right.gif"), x+w-rc.width, y+tp.height, x+w,            y+h);

    addStaticSpriteBG(sideleft);
    addStaticSpriteBG(filler);
    addStaticSpriteBG(sideright);

    // boundary to walk on
    addBoundary(new Boundary(x, y, x+w, y));
  }

  // add coins over a horizontal stretch  
  void addCoins(float x, float y, float w) {
    float step = 16, i = 0, last = w/step;
    for(i=0; i<last; i++) {
      addForPlayerOnly(new Coin(x+8+i*step,y));
    }
  }

  // And finally, the end of the level!
  void addGoal(float xpos, float hpos) {
    hpos += 1;
    // background post
    Sprite goal_b = new Sprite("graphics/assorted/Goal-back.gif");
    goal_b.align(CENTER, BOTTOM);
    goal_b.setPosition(xpos, hpos);
    addStaticSpriteBG(goal_b);
    // foreground post
    Sprite goal_f = new Sprite("graphics/assorted/Goal-front.gif");
    goal_f.align(CENTER, BOTTOM);
    goal_f.setPosition(xpos+32, hpos);
    addStaticSpriteFG(goal_f);
    // the finish line rope
    addForPlayerOnly(new Rope(xpos, hpos-16));
  }

  // places a single tube with all the boundaries and behaviours
  void addTube(float x, float y, TeleportTrigger teleporter) {
    // pipe head as foreground, so we can disappear behind it.
    Sprite pipe_head = new Sprite("graphics/assorted/Pipe-head.gif");
    pipe_head.align(LEFT, BOTTOM);
    pipe_head.setPosition(x, y-16);
    addStaticSpriteFG(pipe_head);

    // active pipe; use a removable boundary for the top
    if (teleporter!=null) {
      Boundary lid = new PipeBoundary(x, y-16-32, x+32, y-16-32);
      teleporter.setLid(lid);
      addBoundary(lid);
    }

    // plain pipe; use a normal boundary for the top
    else { 
      addBoundary(new Boundary(x, y-16-32, x+32, y-16-32));
    }

    // pipe body as background
    Sprite pipe = new Sprite("graphics/assorted/Pipe-body.gif");
    pipe.align(LEFT, BOTTOM);
    pipe.setPosition(x, y);
    addStaticSpriteBG(pipe);

    if (teleporter!=null) {
      // add a trigger region for active pipes
      addTrigger(teleporter);
      // add an invisible boundery inside the pipe, so
      // that actors don't fall through when the top
      // boundary is removed.
      addBoundary(new Boundary(x+1, y-16, x+30, y-16));
      // make sure the teleport trigger has the right
      // dimensions and positioning.
      teleporter.setArea(x+16, y-20, 16, 4);
    }

    // And add side-walls, so that actors don't run
    // through the pipe as if it weren't there.
    addBoundary(new Boundary(x, y, x, y-16-32));
    addBoundary(new Boundary(x+32, y-16-32, x+32, y));
  }
  
  // places a single tube with all the boundaries and behaviours, upside down
  void addUpsideDownTube(float x, float y) {
    // pipe body as background
    Sprite pipe = new Sprite("graphics/assorted/Pipe-body.gif");
    pipe.align(LEFT, TOP);
    pipe.setPosition(x, y);
    addStaticSpriteBG(pipe);

    // pipe head as foreground, so we can disappear behind it.
    Sprite pipe_head = new Sprite("graphics/assorted/Pipe-head.gif");
    pipe_head.align(LEFT, TOP);
    pipe_head.flipVertical();
    pipe_head.setPosition(x, y+16);
    addStaticSpriteFG(pipe_head);

    // And add side-walls and the bottom "lid.
    addBoundary(new Boundary(x, y+16+32, x, y));
    addBoundary(new Boundary(x+32, y, x+32, y+16+32));

    addBoundary(new Boundary(x+32, y+16+32, x, y+16+32));
  }

}
