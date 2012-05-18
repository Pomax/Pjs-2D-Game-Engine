/**
 * This is kind of a "master" class with level construction
 * methods, used by extensions to populate a level.
 */
abstract class MarioLayer extends LevelLayer {

  // fallthrough constructors
  MarioLayer(Level parent, float w, float h) { 
    super(parent, w, h);
  }
  MarioLayer(Level parent, float w, float h, float ox, float oy, float sx, float sy) { 
    super(parent, w, h, ox, oy, sx, sy);
  }

  // add the bit of ground that runs all the
  // way from the start to the finish
  void addBottom(String tileset, float x, float y, float w, float h) {
    // top of the ground
    Sprite groundsprite = new Sprite("graphics/backgrounds/"+tileset+"-top.gif");
    TilingSprite groundline = new TilingSprite(groundsprite, x, y, w + groundsprite.width, y + groundsprite.height);
    addStaticSpriteBG(groundline);
    // ground filler
    TilingSprite groundfiller = new TilingSprite(new Sprite("graphics/backgrounds/"+tileset+"-filler.gif"), x, y + groundsprite.height, w + groundsprite.width, y + h);
    addStaticSpriteBG(groundfiller);
    // remember to add a boundary
    addBoundary(new Boundary(x-20, y-8, w+20, y-8));
  }

  // this creates the raised, angled sticking-out-ground bit.
  // it's actually a sprite, not a rotated generated bit of ground.
  void addSlant(float x, float y) {
    Sprite groundslant = new Sprite("graphics/backgrounds/ground-slant.gif");
    groundslant.align(RIGHT, TOP);
    groundslant.setPosition(x, y - groundslant.height);
    addStaticSpriteBG(groundslant);
    addBoundary(new Boundary(x, y + 48 - groundslant.height, x + 48, y - groundslant.height));
  }

  // this creates a platform with soil filling underneath
  void addGroundPlatform(String tileset, float x, float y, float w, float h) {
    // top layer
    Sprite lc = new Sprite("graphics/backgrounds/"+tileset+"-corner-left.gif");
    Sprite tp = new Sprite("graphics/backgrounds/"+tileset+"-top.gif");
    Sprite rc = new Sprite("graphics/backgrounds/"+tileset+"-corner-right.gif");
    lc.setPosition(x, y);
    rc.setPosition(x+w-rc.width, y);
    TilingSprite toprow = new TilingSprite(tp, x+lc.width, y, x+(w-rc.width), y+tp.height);

    addStaticSpriteBG(lc);
    addStaticSpriteBG(toprow);
    addStaticSpriteBG(rc);
    addBoundary(new Boundary(x-lc.width/2, y-tp.height/2, x+w-rc.width/2, y-tp.height/2));

    // sides/filler
    Sprite ls = new Sprite("graphics/backgrounds/"+tileset+"-side-left.gif");
    Sprite rs = new Sprite("graphics/backgrounds/"+tileset+"-side-right.gif");
    Sprite fl = new Sprite("graphics/backgrounds/"+tileset+"-filler.gif");

    TilingSprite sideleft  = new TilingSprite(ls, x, y+lc.height, x+ls.width, y+h-lc.height);
    TilingSprite sideright = new TilingSprite(rs, x+w-rc.width, y+rc.height, x+w, y+h-rc.height);
    TilingSprite filler    = new TilingSprite(fl, x+ls.width, y+ls.height, x+(w-fl.width), y+(h-fl.height));

    addStaticSpriteBG(sideleft);
    addStaticSpriteBG(filler);
    addStaticSpriteBG(sideright);
  }

  // convenient shortcut method for placing three coins at once
  void addCoin(float x, float y) {
    addForPlayerOnly(new Coin(x-16, y - 40));
    addForPlayerOnly(new Coin(   x, y - 40));
    addForPlayerOnly(new Coin(x+16, y - 40));
  }

  // and some mysterious coins of which we have no idea what they do
  void addDragonCoins() {
    addForPlayerOnly(new DragonCoin(972, 264));
    addForPlayerOnly(new DragonCoin(1490, 256));
  }

  // places a single tube with all the boundaries and behaviours
  void addTube(float x, float y, TeleportTrigger teleporter) {
    // pipe head as foreground, so we can disappear behind it.
    Sprite pipe_head = new Sprite("graphics/assorted/Pipe-head.gif");
    pipe_head.align(RIGHT, BOTTOM);
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
    pipe.align(RIGHT, BOTTOM);
    pipe.setPosition(x, y);
    addStaticSpriteBG(pipe);

    if (teleporter!=null) {
      // add a trigger region for active pipes
      addTrigger(teleporter);
      // add an invisible boundery inside the pipe, so
      // that actors don't fall through when the top
      // boundary is removed.
      addBoundary(new Boundary(x+1, y-16, x+30, y-16));
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
    pipe.align(RIGHT, TOP);
    pipe.setPosition(x, y);
    addStaticSpriteBG(pipe);

    // pipe head as foreground, so we can disappear behind it.
    Sprite pipe_head = new Sprite("graphics/assorted/Pipe-head.gif");
    pipe_head.align(RIGHT, TOP);
    pipe_head.flipVertical();
    pipe_head.setPosition(x, y+16);
    addStaticSpriteFG(pipe_head);

    // And add side-walls and the bottom "lid.
    addBoundary(new Boundary(x, y+16+32, x, y));
    addBoundary(new Boundary(x+32, y, x+32, y+16+32));

    addBoundary(new Boundary(x+32, y+16+32, x, y+16+32));
  }

  // some platforms made up of normal blocks
  void addBlockPlatforms(float x, float y, int howmany) {
    PassThroughBlock p = null;
    for (float e=x+14*howmany; x<e; x+=16) {
      PassThroughBlock n = new PassThroughBlock(x, y);
      addBoundedInteractor(n);
      if (p!=null) { 
        n.setPrevious(p); 
        p.setNext(n);
      }
      p = n;
    }
  }

  // And finally, the end of the level!
  void addGoal(float xpos, float hpos) {
    hpos -= 7;
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
    addForPlayerOnly(new Rope(xpos+24, hpos-16));
  }
}
