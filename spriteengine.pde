/***************************************
 *                                     *
 *      LET'S GET OUR NINTENDO ON!     *
 *                                     *
 ***************************************/

// This value determines how much we "slide" when we walk
float DAMPENING = 0.75;

// This value determines how much 'gravity' we experience
float DOWN_FORCE = 0.7;

// This value determines how strong gravity's hold on us is.
// The higher the value, the more speed we pick up as we fall.
float ACCELERATION = 1.3;

// and this is the level we'll be playing.
MarioLevel mainLevel, darkLevel, level;

// sprites in this demo are mostly multiples of 16
final int BLOCK = 16;
int screenWidth, screenHeight;

// boilerplate
void setup() {
  //  size(32*BLOCK, 27*BLOCK, (P3Dmode ? P3D : P2D));
  size(32*BLOCK, 27*BLOCK, P2D);
  screenWidth = width;
  screenHeight = height;
  frameRate(30);
  // set up the sound manager
  SoundManager.init(this);
  // It is essential that this is called
  // before any sprites are made:
  SpriteMapHandler.setSketch(this);
  reset();
}

// resetting is important
void reset() {
  level = null;
  SoundManager.reset();
  if (javascript!=null) { 
    javascript.resetActorCount();
  }
  // set up two "persistent" levelsz
  mainLevel = new MainLevel(width, height, 4, 1);
  darkLevel = new DarkLevel(width, height, 1, 1);

  // set up our running level as "main"
  setLevel(mainLevel);
}

void setLevel(MarioLevel newLevel) {
  if (level!=null) {
    SoundManager.stop(level);
    // carry over mario to the new level
    newLevel.updateMario(level.mario);
  }
  level = newLevel;
  SoundManager.loop(level);
}

// Render mario in glorious canvas definition
void draw() {
  if (level.finished && level.swappable) { 
    reset();
  }
  else { 
    level.draw();
  }
  resetMatrix();
  image(SoundManager.volume_overlay, width-20, 4);
  if (javascript!=null) {
    javascript.recordFramerate(frameRate);
  }
}

// pass-through for keyboard events
void keyPressed() { 
  level.keyPressed(key, keyCode);
}
void keyReleased() { 
  level.keyReleased(key, keyCode);
}

void mousePressed() {
  // mute button! very important
  if (mouseX>width-20 && mouseY<20) { 
    SoundManager.mute();
  }
  // normal passthrough
  else { 
    level.mousePressed(mouseX, mouseY, mouseButton);
  }
}

void mouseReleased() {
  level.mouseReleased(mouseX, mouseY, mouseButton);
}

// shortcut method for setting up "game" views
void setGameView() {
  level.showBackground(true);
  level.showBoundaries(false);
  level.showPickups(true);
  level.showDecals(true);
  level.showInteractors(true);
  level.showActors(true);
  level.showForeground(true);
  level.showTriggers(false);
}

// shortcut method for setting up "game design" views
void setDesignView() {
  level.showBackground(false);
  level.showBoundaries(true);
  level.showPickups(true);
  level.showDecals(true);
  level.showInteractors(true);
  level.showActors(true);
  level.showForeground(false);
  level.showTriggers(true);
}

// debug: how many actors are loaded?
int getActorCount() {
  return level.getActorCount();
}

// TEST!
void keyPressFromPage(int keyCode) { 
  level.keyPressed(' ', keyCode);
}
void keyReleaseFromPage(int keyCode) { 
  level.keyReleased(' ', keyCode);
}


/***************************************
 *                                     *
 *        LEVEL IMPLEMENTATION         *
 *                                     *
 ***************************************/

class MarioLevel extends Level {
  Player mario;
  String wintext = "Goal!";
  int endCount = 0;

  MarioLevel(float w, float h) { 
    super(w, h);
  }

  void updateMario(Player newMario) {
    updatePlayer(mario, newMario);
    mario = newMario;
  }

  /**
   * Now then, the draw loop: render mario in
   * glorious canvas definition.
   */
  void draw() {
    if (!finished) {
      super.draw();
      mario.constrainPosition();
      viewbox.track(this, mario);
      if (javascript!=null) {
        javascript.setCoordinate(mario.x, mario.y);
      }
    }

    // After mario's won, fade to black with
    // the win text in white. After 7.5 seconds,
    // (which is how long the sound plays), signal
    // that this level can be swapped out.
    else {
      endCount++;
      fill(255);
      textFont(createFont("fonts/acmesa.ttf", 62));
      text(wintext, (512-textWidth(wintext))/2, 192);
      fill(0, 8);
      rect(0, 0, width, height);
      if (endCount>7.5*frameRate) {
        SoundManager.stop(this);
        setSwappable();
      }
    }
  }
}

/**
 * Test level implementation
 */
class MainLevel extends MarioLevel {

  // constructor sets up a level and level layer
  MainLevel(float w, float h, int x_repeat, int y_repeat)
  {
    super(w*x_repeat, h*y_repeat);
    setViewBox(0, 0, w, h);
    LevelLayer layer;

    layer = new BackgroundColorLayer(this, width, height, color(0, 100, 190));
    addLevelLayer("color", layer);

    float scaleFactor = 0.75;
    layer = new BackgroundLayer(this, width + (scaleFactor*w/2) /* HACK! */ - 21, height, 0, 0, scaleFactor, scaleFactor);
    addLevelLayer("background 1", layer);

    layer = new MainLevelLayer(this, width, height);
    if (layer.players.size()==0 || mario == null) {
      mario = new Mario();
      mario.setPosition(32, 383);
      layer.addPlayer(mario);
    }
    addLevelLayer("main", layer);

    // And of course some background music.
    SoundManager.load(this, "audio/bg/Overworld.mp3");
  }
  
  void draw() {
    super.draw();
  }

  /**
   * If mario loses, we must end the level prematurely:
   */
  void end() {
    SoundManager.pause(this);
    super.end();
  }

  /**
   * But if he wins, we end the level properly:
   */
  void finish() {
    SoundManager.pause(this);
    super.finish();
  }
}

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

/**
 * Plain color background layer
 */
class BackgroundColorLayer extends MarioLayer {
  BackgroundColorLayer(Level parent, float w, float h, color c) {
    super(parent, w, h);
    backgroundColor = c;
  }
}

/**
 * Background with level layer
 */
class BackgroundLayer extends MarioLayer {
  // fairly simple constructor
  BackgroundLayer(Level parent, float w, float h, float ox, float oy, float sx, float sy) {
    super(parent, w, h, ox, oy, sx, sy);

    // repeating background sprite image
    Sprite bgsprite = new Sprite("graphics/backgrounds/sky_2.gif");
    bgsprite.align(RIGHT, TOP);
    TilingSprite backdrop = new TilingSprite(bgsprite, 0, 0, width, height);
    addStaticSpriteBG(backdrop);

    // flat ground
    addBottom("ground", 0, height+8, width, 16);

    // teleport-in tube
    addUpsideDownTube(64, -16);
    // teleport-out tube
    addTube(64, height, new LayerTeleportTriggerUp(64+8, height-24, 16, 2, 594, 335, "main"));

/*
    // coin block boos! O_O
    for(int x = 384; x < width-176; x+=48) {
      addBoundedInteractor(new CoinBlockBoo(x, height - 1*48));
    }
*/

    // goal
    addGoal(width-64, height+8);
  }
}

/**
 * The test implementaiton of the Level class
 * models the first normal level of Super Mario
 * World, "Yoshi's Island 1". With some liberties
 * taken, because this is a test.
 */
class MainLevelLayer extends MarioLayer {
  /**
   * Test level implementation
   */
  MainLevelLayer(Level parent, float w, float h)
  {
    super(parent, w, h);
    textFont(createFont("fonts/acmesa.ttf", 12));

    // repeating background sprite image
    Sprite bgsprite = new Sprite("graphics/backgrounds/sky.gif");
    bgsprite.align(RIGHT, TOP);
    TilingSprite backdrop = new TilingSprite(bgsprite, 0, 0, width, height);
    addStaticSpriteBG(backdrop);

    // level components
    addGround("ground");
    addBottom("ground", 0, height-40, width, 40);    
    addBushes();
    addCloudPlatforms();
    addBlockPlatforms(1064, 264, 16);
    addSpecialBlocks();
    addCoins();
    addDragonCoins();
    addFlyingKoopas();
    addTriggers();
    addTubes();
  }

  // "ground" parts of the level
  void addGround(String tileset) {
    // some random platforms
    addGroundPlatform(tileset, 928, 432/2, 96, 116);
    addGroundPlatform(tileset, 920, 432/2+48, 32, 70);
    addGroundPlatform(tileset, 912, 432/2 + 100, 128, 86);
    addGroundPlatform(tileset, 912+64, 432/2 + 130, 128, 50);

    addSlant(256, height-48);
    addSlant(1300, height-48);
    addSlant(1350, height-48);

    addGroundPlatform(tileset, 1442, 432/2 + 100, 128, 86);
    addGroundPlatform(tileset, 1442+64, 432/2 + 130, 128, 50);
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

  // clouds platforms!
  void addCloudPlatforms() {
    addBoundary(new Boundary(54 +   0, 96 +   0, 105 +   0, 96 +   0));
  }

  // coin blocks (we only use one)
  void addSpecialBlocks() {
    MushroomBlock mb = new MushroomBlock(1110, 208);
    addBoundedInteractor(mb);
  }

  // some coins in tactical places
  void addCoins() {
    // coin chain!
    int set = 0;
    addCoin(640+48*set++, height-48);
    addCoin(640+48*set++, height-48);
    addCoin(640+48*set++, height-48);
    addForPlayerOnly(new Coin(640+48*set++-16, height-48-40));

    // coins on top of a platform at the end of the level
    addCoin(1448, 316);
    addCoin(1448+84, 316);
  }

  // Then, some flying koopas for getting to coins in the clouds
  void addFlyingKoopas() {
    for (int i=0; i<3; i++) {
      FlyingKoopa fk = new FlyingKoopa(150, 175 + i*30);
      fk.active.sprite.setPathOffset(i*40);
      addInteractor(fk);
    }
  }

  // In order to effect "just-in-time" sprite placement,
  // we set up some trigger regions.
  void addTriggers() {
    // when tripped, place a koopa on top of the slanted ground
    addTrigger(new SlantKoopaTrigger(16, height-48-20, 32, 20));
    // when tripped, spawn a mushroom 350 pixels to the right (behind the bush)
    addTrigger(new PowerupTrigger(150, height-48-16, 5, 16));
    // when tripped, add a koopa under the coin chain
    addTrigger(new KoopaTrigger(412, 0, 5, height, 350, height-49, -0.2, 0));
    // when tripped, place a koopa on one of the platforms in the middle
    addTrigger(new KoopaTrigger(562, 0, 5, height, 350, 307, 0.2, 0));
    // when tripped place a koopa on top of the passthrough block platform
    addTrigger(new KoopaTrigger(916, 0, 5, height, 350, 250, -0.2, 0));
    // when tripped, release a banzai bill
    addTrigger(new BanzaiBillTrigger(1446, 310, 5, 74, 400, 432-48-24, -6, 0));
  }

  // To demonstrate screen changing, also add some tubes
  void addTubes() {
    // level start test pipes
    //addTube(64, height-16, null);
    //addTube(128, height-48, null);
    // plain pipe
    addTube(580, height-48, null);
    // teleporting pipe to the start of the level
    addTube(778, height-48, new LayerTeleportTrigger(786, height-66, 16, 2, 78, -32, "background 1"));
    // end of the level, right above the goal posts
    addUpsideDownTube(width - 200, -16);
    // teleporting pipe to the bonus level
    addTube(width-32, height-48, new BonusLevelTrigger(width-24, height-66, 16, 2, 16, height-32));
  }
}


/**
 * To show level swapping we also have a small "dark"
 * level that is teleport from, and back out of.
 */
class DarkLevel extends MarioLevel
{
  // constructor sets up a level and level layer
  DarkLevel(float w, float h, int x_repeat, int y_repeat)
  {
    super(w*x_repeat, h*y_repeat);
    setViewBox(0, 0, w, h);
    addLevelLayer("color", new BackgroundColorLayer(this, width, height, color(0, 0, 100)));

    LevelLayer layer = new DarkLevelLayer(this, width, height);
    if (layer.players.size()==0 || mario==null) {
      mario = new Mario();
      mario.setPosition(16, height-32);
      mario.setImpulse(0, -24);
      layer.addPlayer(mario);
    }
    addLevelLayer("main", layer);

    // And of course some background music.
    SoundManager.load(this, "audio/bg/Bonus.mp3");
  }

  class DarkLevelLayer extends MarioLayer {
    DarkLevelLayer(Level parent, float w, float h) {
      super(parent, w, h);

      // repeating background sprite image
      Sprite bgsprite = new Sprite("graphics/backgrounds/bonus.gif");
      bgsprite.align(RIGHT, TOP);
      TilingSprite backdrop = new TilingSprite(bgsprite, 0, 0, width, height);
      addStaticSpriteBG(backdrop);      

      // set up ground
      addBottom("cave", 0, h, w, 40);
      float x, y, wth;
      for (int i=1; i<=4; i++) {
        x = 8+i*56;
        y = h-i*48;
        wth = w-2*i*56;
        addGroundPlatform("cave", x, y, wth, 64);
        for (int j=1; j<wth/48; j++) {
          addCoin(x+24+(j-1)*48, y+16);
        }
      }

      // bonus level reward! firepower~
      FireFlowerBlock fb = new FireFlowerBlock(w/2, h-5.25*48);
      addBoundedInteractor(fb);

      // set up two tubes
      addTube(0, height - 8, null);
      // second tube teleports back to level
      addTube(width-32, height-8, new MainLevelTrigger(width-24, height-26, 16, 2, mainLevel.width-184, -16));
      // and some Koopas
      Koopa koopa;
      for (int i=1; i<=4; i++) {
        koopa = new Koopa(i * width/5, height-16);
        koopa.addForces(-0.2, 0);
        koopa.persistent = true;
        addInteractor(koopa);
      }
    }
  }
}

/***************************************
 *                                     *
 *          ACTORS: MARIO              *
 *                                     *
 ***************************************/


/**
 * Mario, that lovable, portly, moustachioed man.
 */
class Mario extends Player {

  String spriteset = "mario";
  String marioType = "small";

  // every 'step' has an impulse of 1.3
  float speedStep = 1.3;

  // jumping uses an impulse 21 times that of a step
  float speedHeight = 21;

  // The buttons that get to control Mario
  int VK_UP=87, VK_LEFT=65, VK_DOWN=83, VK_RIGHT=68;  // WASD controls
  int BUTTON_A=81, BUTTON_B=69;                       // Q and E for jump/shoot
  
  void mousePressed(int mx, int my, int button) {
    if(button==LEFT) { keyPressed('Q',81); }
    else if(button==RIGHT) { keyPressed('E',69); }
  }
  void mouseReleased(int mx, int my, int button) {
    if(button==LEFT) { keyReleased('Q',81); }
    else if(button==RIGHT) { keyReleased('E',69); }
  }
  
  /**
   * The Mario constructor
   */
  Mario() {
    this("Mario", DAMPENING, DAMPENING);
  }

  Mario(String name, float xdamp, float ydamp) {
    super(name, xdamp, ydamp);
    setForces(0, DOWN_FORCE);
    setAcceleration(0, ACCELERATION);
    // by default, we're small mario
    setupStates("small");
    // and these are the keys we will be allowed to use.
    keyCodes = new int[] {VK_UP, VK_LEFT, VK_DOWN, VK_RIGHT, BUTTON_A, BUTTON_B};
  }

  /**
   * Set up a number of states for Mario to be in.
   */
  void setupStates(String setType) {
    states.clear();
    marioType = setType;

    // when not moving
    State standing = new State("standing", "graphics/mario/"+setType+"/Standing-"+spriteset+".gif");
    standing.sprite.align(CENTER, BOTTOM);
    addState(standing);

    // when either running right or left
    State running = new State("running", "graphics/mario/"+setType+"/Running-"+spriteset+".gif", 1, 4);
    running.sprite.align(CENTER, BOTTOM);
    running.sprite.setAnimationSpeed(0.75);
    addState(running);

    // when [down] is pressed
    State crouching = new State("crouching", "graphics/mario/"+setType+"/Crouching-"+spriteset+".gif");
    crouching.sprite.align(CENTER, BOTTOM);
    addState(crouching);

    // when [up] is pressed
    State looking = new State("looking", "graphics/mario/"+setType+"/Looking-"+spriteset+".gif");
    looking.sprite.align(CENTER, BOTTOM);
    addState(looking);

    // when pressing the A (jump) button
    State jumping = new State("jumping", "graphics/mario/"+setType+"/Jumping-"+spriteset+".gif");
    jumping.sprite.align(CENTER, BOTTOM);
    jumping.sprite.addPathLine(0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 24);
    SoundManager.load(jumping, "audio/Jump.mp3");
    addState(jumping);

    // when pressing the A button while crouching
    State crouchjumping = new State("crouchjumping", "graphics/mario/"+setType+"/Crouching-"+spriteset+".gif");
    crouchjumping.sprite.align(CENTER, BOTTOM);
    crouchjumping.sprite.addPathLine(0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 24);
    SoundManager.load(crouchjumping, "audio/Jump.mp3");
    addState(crouchjumping);

    // when pressing the B (shoot) button
    State spinning = new State("spinning", "graphics/mario/"+setType+"/Spinning-"+spriteset+".gif", 1, 4);
    spinning.sprite.align(CENTER, BOTTOM);
    spinning.sprite.addPathLine(0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 24);
    SoundManager.load(spinning, "audio/Spin jump.mp3");
    addState(spinning);

    // if we mess up, and we're small, we lose...
    if (setType=="small") {
      State dead = new State("dead", "graphics/mario/"+setType+"/Dead-"+spriteset+".gif", 1, 2);
      dead.sprite.align(CENTER, BOTTOM);
      dead.sprite.setAnimationSpeed(0.5);
      dead.sprite.setNoRotation(true);
      dead.sprite.setLooping(false);
      dead.sprite.addPathCurve(0, 0, 1, 1, 0, 
      0, -50, 
      0, 250, 
      0, 1200, 1, 1, 0, 72, 1);
      SoundManager.load(dead, "audio/Dead mario.mp3");
      addState(dead);
    }

    // Finally, we make sure to start off in the "standing" state
    setCurrentState("standing");
  }

  /**
   * We need to be able to control Mario, so let's
   * define his behaviour based on user input!
   */
  void handleInput() {

    // When the left or right key is presed, we
    // should run. Unless we're stuck in a state
    // that locks us in our place:
    if (active.name != "crouching" && active.name != "looking") {
      if (keyDown[VK_LEFT]) {
        // when we walk left, we need to flip the sprite
        setHorizontalFlip(true);
        // walking left means we get a negative impulse along the x-axis:
        addImpulse(-speedStep, 0);
        setViewDirection(-1, 0);
      }
      if (keyDown[VK_RIGHT]) {
        // when we walk right, we need to NOT flip the sprite =)
        setHorizontalFlip(false);
        // walking right means we get a positive impulse along the x-axis:
        addImpulse( speedStep, 0);
        setViewDirection(1, 0);
      }
    }

    // Because some states will not allow use to change,
    // such as jump animations, we check whether we're
    // allowed to change our state before we check keys.
    if (active.mayChange())
    {
      // The jump button is pressed! Should we jump? How do we jump?
      if (keyDown[BUTTON_A] && boundaries.size()>0) {
        if (active.name != "jumping" && active.name != "crouchjumping" && active.name != "spinning") {
          // first off, jumps may not auto-repeat, so we lock the jump button
          ignore(BUTTON_A);
          // make sure we unglue ourselves from the platform we're standing on:
          detachAll();
          // then generate a massive impulse upward:
          addImpulse(0, speedHeight*-speedStep);
          // now, if we're crouching, we need to crouch-jump.
          // Otherwise, we can jump normally.
          if (active.name == "crouching") { 
            setCurrentState("crouchjumping");
          }
          else { 
            setCurrentState("jumping");
          }
          SoundManager.play(active);
        }
      }

      // The shoot button is pressed! When we don't have a shooty power-up,
      // this makes Mario spin-jump. But should we? And How?
      else if (keyDown[BUTTON_B] && boundaries.size()>0) {
        // first off, shooting and spin jumping may not auto-repeat, so we lock the shoot button
        ignore(BUTTON_B);
        if (marioType=="fire" && active.name != "crouching") {
          shoot();
        }
        else if (marioType!="fire" && active.name != "jumping" && active.name != "crouchjumping" && active.name != "spinning") {
          // make sure we unglue ourselves from the platform we're standing on:
          detachAll();
          // then generate a massive impulse upward:
          addImpulse(0, speedHeight*-speedStep);
          // and then make sure we spinjump, rather than jump normally
          setCurrentState("spinning");
          SoundManager.play(active);
        }
      }
      // The down button is pressed: crouch
      else if (keyDown[VK_DOWN]) {
        if (boundaries.size()==1 && boundaries.get(0) instanceof PipeBoundary) {
          ((PipeBoundary)boundaries.get(0)).teleport();
        }
        setCurrentState("crouching");
      }
      // The up button is pressed: look up
      else if (keyDown[VK_UP]) {
        setCurrentState("looking");
      }
      // The left and/or right buttons are pressed: run!
      else if (keyDown[VK_LEFT] || keyDown[VK_RIGHT]) {
        setCurrentState("running");
      }
      // okay, nothing's being pressed. Let's just stand there.
      else { 
        setCurrentState("standing");
      }
    }
  }

  /**
   * If Mario loses, remove him from the level.
   */
  void handleStateFinished(State which) {
    if (which.name == "dead") {
      // well, we died.. restart!
      level.end();
      level.setSwappable();
    }
  }

  /**
   * When Mario touches down on a platform,
   * which state should he switch to?
   */
  void attachTo(Boundary boundary) {
    super.attachTo(boundary);
    // After crouch-jumping, Mario should be crouching
    if (active.name=="crouchjump") {
      setCurrentState("crouching");
    }
    // after other jumps, he should be standing.
    else {
      setCurrentState("standing");
    }
  }

  /**
   * What happens when we touch another actor?
   */
  void overlapOccurredWith(Actor other, float[] direction) {
    if (other instanceof Koopa) {
      Koopa koopa = (Koopa) other;
      float angle = direction[2];

      // We bopped a koopa on the head!
      float tolerance = radians(75);
      if (PI/2 - tolerance <= angle && angle <= PI/2 + tolerance) {
        boolean shouldJump = koopa.squish();
        if (shouldJump) {
          setImpulse(0, ACCELERATION*speedHeight*-speedStep);
          if (active.name!="spinning") {
            setCurrentState("jumping");
          }
        }
      }

      // Oh no! We missed and touched a koopa!
      else { 
        die();
      }
    }
  }

  /**
   * What happens when we die?
   */
  void die() {
    // wait! are we big? we don't die when we're big!
    if (getState("dead")==null) {
      disableInteractionFor(48);
      setupStates("small");
    }
    // okay, no, we're small. We lose =(
    else {
      setInteracting(false);
      setCurrentState("dead");
      SoundManager.pause(level);
      SoundManager.play(active);
    }
  }

  /**
   * What happens when we get pickups?
   */
  void pickedUp(Pickup pickup) {
    if (pickup.name=="Regular coin") {
      // increase our score
    }
    else if (pickup.name=="Dragon coin") {
      // increase our secret dragon score
    }
    else if (pickup.name=="Mushroom") {
      // become big!
      powerUp();
    }
    else if (pickup.name=="Flower") {
      // obtain fire flower powers!
      flowerPowerUp();
    }
  }

  /**
   * Big mario has different sprites
   */
  void powerUp() {
    setupStates("big");
  }

  /**
   * Fire flower mario has different sprites, too
   */
  void flowerPowerUp() {
    setupStates("fire");
  }

  /**
   * Shoot a fire blob... at the mouse pointer!
   */
  void shoot() {
    // get the unified coordinate values for mario, and the mouse cursor...
    float[] mapped = layer.mapCoordinateToScreen(getX(), getY()-height/2);
    float ax = mapped[0], ay = mapped[1];
    mapped = layer.mapCoordinateFromScreen(mouseX, mouseY);
    float mx = mapped[0], my = mapped[1];
    // because the fire blob gets fired in the direction of the mouse!
    float dx = mx-ax, dy = my-ay,
          len = sqrt(dx*dx + dy*dy),
          speed = 10;
    dx = speed*dx/len;
    dy = speed*dy/len;
    // oh my god, precision aiming fire Mario O_O!
    FireBlob fireblob = new FireBlob(x, y-height/2, dx, dy);
    layer.addForInteractorsOnly(fireblob);
    // also, make a pew pew sound.
    SoundManager.load(fireblob, "audio/Squish.mp3");
    SoundManager.play(fireblob);
  }
}

/***************************************
 *                                     *
 *      INTERACTORS: RED KOOPA         *
 *                                     *
 ***************************************/


/**
 * A red koopa trooper actor
 */
class Koopa extends Interactor {

  /**
   * The constructor for the koopa trooper
   * is essentially the same as for Mario.
   */
  Koopa(float mx, float my) {
    super("Red koopa", DAMPENING, DAMPENING);
    setPosition(mx, my);
    setForces(0, DOWN_FORCE);
    setAcceleration(0, ACCELERATION);
    setupStates();
  }

  /**
   * So, what can koopa troopers do?
   */
  void setupStates() {
    // when walking around
    State walking = new State("walking", "graphics/enemies/Red-koopa-walking.gif", 1, 2);
    walking.sprite.align(CENTER, BOTTOM);
    walking.sprite.setAnimationSpeed(0.25);
    addState(walking);

    // when just standing, doing nothing
    State standing = new State("standing", "graphics/enemies/Red-koopa-standing.gif", 1, 2);
    standing.sprite.align(CENTER, BOTTOM);
    addState(standing);

    // if we get squished, we first get naked...
    State naked = new State("naked", "graphics/enemies/Naked-koopa-walking.gif", 1, 2);
    naked.sprite.setAnimationSpeed(0.25);
    naked.sprite.align(CENTER, BOTTOM);
    SoundManager.load(naked, "audio/Squish.mp3");
    addState(naked);

    // if we get squished again, we die!
    State dead = new State("dead", "graphics/enemies/Dead-koopa.gif");
    dead.sprite.align(CENTER, BOTTOM);
    dead.sprite.addPathLine(0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 12);
    dead.sprite.setLooping(false);
    SoundManager.load(dead, "audio/Squish.mp3");
    addState(dead);

    // by default, the koopa will be walking
    setCurrentState("walking");
  }

  /**
   * Mario squished us! O_O
   *
   * Should we just lose our shell, or have we
   * been properly squished dead?
   */
  boolean squish() {
    // if we're scheduled for removal,
    // don't do anything.
    if (remove) return false;

    // We're okay, we just lost our shell.
    if (active.name != "naked" && active.name != "dead") {
      setCurrentState("naked");
      SoundManager.play(active);
      // trigger some hitpoints
      layer.addDecal(new HitPoints(x, y, 100));

      // mario should jump after trying to squish us
      return true;
    }

    // Ohnoes! we've been squished properly!
    // make sure we stop moving forward
    setForces(0, 0);
    setInteracting(false);
    setCurrentState("dead");
    SoundManager.play(active);
    // trigger some hitpoints
    layer.addDecal(new HitPoints(x, y, 200));
    // mario should also jump after squishing us dead
    return true;
  }

  /**
   * "when state finishes" behaviour: when the
   * "blargh, I am dead!" state is done, we need
   * to remove this koopa from the game.
   */
  void handleStateFinished(State which) {
    if (which.name=="dead") {
      removeActor();
    }
  }

  /**
   * Turn around when we walk into a wall
   */
  void gotBlocked(Boundary b, float[] intersection) {
    if (intersection[0]-x==0 && intersection[1]-y==0) {
      fx = -fx;
      active.sprite.flipHorizontal();
    }
  }

  void pickedUp(Pickup p) {
    squish();
  }
}


/***************************************
 *                                     *
 *   INTERACTORS: RED KOOPA (FLYING)   *
 *                                     *
 ***************************************/


/**
 * A flying red koopa trooper actor
 */
class FlyingKoopa extends Koopa {
  // are we flying or not?
  boolean flying = true;

  /**
   * The constructor for the koopa trooper
   * basically wraps the normal koopa trooper,
   * but gravity does not apply to this one!
   */
  FlyingKoopa(float mx, float my) {
    super(mx, my);
    setForces(0, 0);
    setAcceleration(0, 0);
  }

  /**
   * So, what can flying koopa troopers do?
   */
  void setupStates() {
    super.setupStates();

    // they can fly!
    State flying = new State("flying", "graphics/enemies/Red-koopa-flying.gif", 1, 2);
    flying.sprite.align(CENTER, BOTTOM);
    flying.sprite.setAnimationSpeed(0.2);
    // in fact, they can do a flying patrolling pattern
    flying.sprite.addPathLine(   0, 0, 1, 1, 0, 
    -100, 0, 1, 1, 0, 
    100);
    flying.sprite.addPathLine(-100, 0, 1, 1, 0, 
    -100, 0, -1, 1, 0, 
    5);
    flying.sprite.addPathLine(-100, 0, -1, 1, 0, 
    0, 0, -1, 1, 0, 
    100);
    flying.sprite.addPathLine(0, 0, -1, 1, 0, 
    0, 0, 1, 1, 0, 
    5);
    SoundManager.load(flying, "audio/Squish.mp3");
    addState(flying);

    // by default, flying koopas fly
    setCurrentState("flying");
  }

  /**
   * When mario squishes us, we lose our wings.
   */
  boolean squish() {
    if (flying) {
      flying = false;
      setForces(-0.2, DOWN_FORCE);
      setAcceleration(0, ACCELERATION);
      SoundManager.play(active);
      // trigger some hitpoints
      layer.addDecal(new HitPoints(x, y, 300));
      setCurrentState("walking");
      return true;
    }
    return super.squish();
  }
}


/***************************************
 *                                     *
 *      INTERACTORS: BANZAI BILL       *
 *                                     *
 ***************************************/


/**
 * The big bullet that comes out of nowhere O_O
 */
class BanzaiBill extends Interactor {

  /**
   * Relatively straight-forward constructor
   */
  BanzaiBill(float mx, float my) {
    super("Banzai Bill", 1, 1);
    setPosition(mx, my);
    setImpulse(-0.5, 0);
    setForces(0, 0);
    setAcceleration(0, 0);
    setupStates();
    // Banzai Bills are destined to fly off-screen
    persistent = false;
    // Banzai Bills do not care about boundaries.
    setPlayerInteractionOnly(true);
  }

  /**
   * Banzai bill flies with great purpose.
   */
  void setupStates() {
    State flying = new State("flying", "graphics/enemies/Banzai-bill.gif");
    flying.sprite.align(LEFT, BOTTOM);
    SoundManager.load(flying, "audio/Banzai.mp3");
    addState(flying);
    setCurrentState("flying");
    SoundManager.play(flying);
  }

  /**
   * state handling is unused, since Banzai
   * Bill only has a single state to be in.
   */
  void handleStateFinished(State which) {
  }

  /**
   * When we hit an actor, they die.
   */
  void overlapOccurredWith(Actor other, float[] overlap) {
    super.overlapOccurredWith(other, overlap);
    if (other instanceof Mario) {
      ((Mario)other).die();
    }
  }
}


/***************************************
 *                                     *
 *   INTERACTORS: THE SPECIAL BLOCK    *
 *                                     *
 ***************************************/


/**
 * Perhaps unexpected, blocks can also be
 * interactors. They get bonked just like
 * enemies, and they do things based on the
 * interaction.
 */
abstract class SpecialBlock extends BoundedInteractor {

  // how many things do we hold?
  int content = 1;

  /**
   * Special blocks just hang somewhere.
   */
  SpecialBlock(String name, float x, float y) {
    super(name);
    setPosition(x, y);
    setForces(0, 0);
    setAcceleration(0, 0);
    setupStates();
    // make the top of this block a platform
    addBoundary(new Boundary(x-width/2, y-height/2, x+width/2, y-height/2));
  }

  /**
   * A special block has an animated sprite,
   * until it's exhausted and turns into a brick.
   */
  void setupStates() {
    // when just hanging in the level
    State hanging = new State("hanging", "graphics/assorted/Coin-block.gif", 1, 4);
    hanging.sprite.setAnimationSpeed(0.25);
    addState(hanging);

    // when Mario jumps into us from below
    State boing = new State("boing", "graphics/assorted/Coin-block.gif", 1, 4);
    boing.sprite.setAnimationSpeed(0.25);
    boing.sprite.setNoRotation(true);
    boing.sprite.setLooping(false);
    boing.sprite.addPathLine(0, 0, 1, 1, 0, 
    0, -8, 1, 1, 0, 
    1);
    boing.sprite.addPathLine(0, -12, 1, 1, 0, 
    0, 0, 1, 1, 0, 
    2);
    SoundManager.load(boing, "audio/Coin.mp3");
    addState(boing);

    // when we've run out of things to spit out
    State exhausted = new State("exhausted", "graphics/assorted/Coin-block-exhausted.gif", 1, 1);
    addState(exhausted);

    setCurrentState("hanging");
  }

  /**
   * are we triggered?
   */
  void overlapOccurredWith(Actor other, float[] overlap) {
    if (active.name=="hanging" || active.name=="exhausted") {
      // First order of business: stop actor movement
      other.rewindPartial();
      other.ix=0;
      other.iy=0;

      // If we're exhausted, shortcircuit
      if (content==0 || active.name=="boing") return;

      // If we're not, see if we got hit
      // from the right direction, and pop
      // some coins out the top if we are.
      float minv = 3*PI/2 - radians(45);
      float maxv = 3*PI/2 + radians(45);
      if (minv <=overlap[2] && overlap[2]<=maxv) {
        content--;
        setCurrentState("boing");
        SoundManager.play(active);
        generate(overlap);
      }
    }
  }

  /**
   * If, at the end of spawning a coin, we're
   * out of coins, turn into a brick.
   */
  void handleStateFinished(State which) {
    if (which.name=="boing") {
      if (content>0) { 
        setCurrentState("hanging");
      }
      else { 
        setCurrentState("exhausted");
      }
    }
  }

  /**
   * Since subclasses can generate different
   * things, we leave it up to them to do
   * figure out which code to call.
   */
  abstract void generate(float[] overlap);
}


/***************************************
 *                                     *
 *     INTERACTORS: THE COIN BLOCK     *
 *                                     *
 ***************************************/


/**
 * A coin block generates coins when hit,
 * and will do so eight times (in this code)
 * before turning into an inactive brick.
 */
class CoinBlock extends SpecialBlock {

  /**
   * A coin block holds eight items
   */
  CoinBlock(float x, float y) {
    super("Coin block", x, y);
    content = 8;
  }

  /**
   * generate a coin
   */
  void generate(float[] overlap) {
    Coin coin = new Coin(x, y-30);
    coin.align(CENTER, BOTTOM);
    coin.setImpulse(random(-3, 3), -10);
    coin.setImpulseCoefficients(1, DAMPENING);
    coin.setForces(0, DOWN_FORCE);
    coin.setAcceleration(0, ACCELERATION);
    coin.persistent = false;
    layer.addForPlayerOnly(coin);
  }
}


/***************************************
 *                                     *
 *   INTERACTORS: THE COIN BLOCK BOO   *
 *                                     *
 ***************************************/


/**
 * A coin block Boo! It acts like a normal
 * coin block, until you turn your back...
 * then it turns into a Boo and chases you!
 */
class CoinBlockBoo extends CoinBlock implements Tracker {
  boolean isBoo = false;

  /**
   * Sneakily, a coin block Boo is
   * the same as a normal coin block.
   */
  CoinBlockBoo(float x, float y) {
    super(x, y);
    setImpulseCoefficients(DAMPENING, DAMPENING);
    setPlayerInteractionOnly(true);
  }

  /**
   * Of course, a coin block Boo
   * has a few more states than a
   * normal coin block.
   */
  void setupStates() {
    super.setupStates();

    // an important state is the "from block to boo" state
    State transition = new State("transition", "graphics/enemies/Coin-boo-transition.gif", 1, 5);
    transition.sprite.setAnimationSpeed(0.4);
    transition.sprite.setLooping(false);
    transition.sprite.addPathPoint(0, 0, 1, 1, 0, 10);
    addState(transition);

    State chasing = new State("chasing", "graphics/enemies/Boo-chasing.gif");
    addState(chasing);

    setCurrentState("hanging");
  }

  /**
   * When we get bricked, give Mario 1000 points
   */
  void setCurrentState(String name) {
    super.setCurrentState(name);
    if (name=="exhausted") {
      // trigger some hitpoints
      layer.addDecal(new HitPoints(x, y, 1000));
    }
  }

  /**
   * Transition to boo-ness
   */
  void handleStateFinished(State which) {
    super.handleStateFinished(which);
    if (which.name=="transition") {
      disableBoundaries();
      setCurrentState("chasing");
      isBoo = true;
    }
  }

  /**
   * How do we deal with tracking?
   * - if we're a coin block, and we can chase, first become a Boo
   * - if we're a Boo, and mario doesn't look at us, chase.
   */
  void track(Actor actor, float vx, float vy, float vw, float vh) {
    // if we got bricked, we never become a Boo =(
    if (active.name=="exhausted") return;

    // if we're pretending to be a coin block, and mario's
    // standing on us, don't blow our cover either.
    if (active.name=="hanging" && havePassenger()) return;

    // if we're too far away, don't track
    if (x<vx-vw || x>vx+vw*2 || y<vy-vh || y>vy+vh*2) return;

    // otherwise: is mario not looking at us?
    if (notLookedAtBy(actor)) {
      // He is! but we're not a Boo yet... become one.
      if (!isBoo) { 
        setCurrentState("transition");
      }

      // We're a Boo! And Mario's not looking! Chase him~!
      else {
        if (active.name != "chasing") {
          setCurrentState("chasing");
        }
        GenericTracker.track(this, actor, 0.3);
      }
    }

    // Uh-oh, he's looking at us...
    else if (active.name == "chasing") {
      isBoo = false;
      enableBoundaries();
      setHorizontalFlip(false);
      setCurrentState("hanging");
    }
  }

  /**
   * Is this actor looking at us?
   */
  boolean notLookedAtBy(Actor actor) {
    // if the actor hasn't moved yet, shortcircuit
    if (actor.direction==-1) return false;
    // if the actor jumped up/down, we pretend it's
    // looking at us if we were already chasing.
    if (actor.direction==PI/2 || actor.direction==PI+PI/2) { 
      return (active.name=="chasing");
    }
    // now the real check: where are we relative to the actor:
    float dx = x - actor.x;
    // and what does that mean for the actor's direction?
    if (dx > 0 && abs(actor.direction-PI)<0.5*PI) {
      // float left
      setHorizontalFlip(true);
      return true;
    }
    if (dx < 0 && abs(actor.direction-PI)>0.5*PI) {
      // float right
      setHorizontalFlip(false);
      return true;
    }
    return false;
  }

  /**
   * When we hit an actor as a Boo, they die.
   */
  void overlapOccurredWith(Actor other, float[] overlap) {
    super.overlapOccurredWith(other, overlap);
    if (isBoo && other instanceof Mario) {
      ((Mario)other).die();
    }
  }
}


/***************************************
 *                                     *
 *   INTERACTORS: THE MUSHROOM BLOCK   *
 *                                     *
 ***************************************/


/**
 * A mushroom block generates powerup mushrooms when hit
 */
class MushroomBlock extends SpecialBlock {

  /**
   * Passthrough constructor
   */
  MushroomBlock(float x, float y) {
    super("Mushroom block", x, y);
  }

  /**
   * Generate a mushroom
   */
  void generate(float[] overlap) {
    Mushroom mushroom = new Mushroom(x, y-16);
    mushroom.setForces((overlap[0]<0 ? 1 : -1) * 2, DOWN_FORCE);
    mushroom.persistent = false;
    layer.addForPlayerOnly(mushroom);
  }
}


/***************************************
 *                                     *
 * INTERACTORS: THE FIRE FLOWER BLOCK  *
 *                                     *
 ***************************************/


/**
 * A fire flower block generates a flower when hit
 */
class FireFlowerBlock extends SpecialBlock {

  /**
   * Passthrough constructor
   */
  FireFlowerBlock(float x, float y) {
    super("Fire flower block", x, y);
  }

  /**
   * Generate a mushroom
   */
  void generate(float[] overlap) {
    Flower flower = new Flower(x, y);
    flower.setImpulse(0, -8);
    flower.setForces(0, 2*DOWN_FORCE);
    flower.persistent = false;
    layer.addForPlayerOnly(flower);
  }
}


/***************************************
 *                                     *
 * INTERACTORS: THE PASS-THROUGH BLOCK *
 *                                     *
 ***************************************/


/**
 * Much like the special blocks, the pass-through
 * block is interactable, and so it counts as an
 * interactor, rather than as a static sprite.
 */
class PassThroughBlock extends BoundedInteractor {

  /**
   * blocks just hang somewhere.
   */
  PassThroughBlock(float x, float y) {
    super("Pass-through block");
    setPosition(x, y);
    setForces(0, 0);
    setAcceleration(0, 0);
    setupStates();
    // make the top of this block a platform
    addBoundary(new Boundary(x-width/2, y-height/2-1, x+width/2, y-height/2-1));
  }

  /**
   * A pass-through block has a static sprite,
   * unless it has been hit. Then it has a rotating
   * sprite that signals it can be jumped through.
   */
  void setupStates() {
    State hanging = new State("hanging", "graphics/assorted/Block.gif");
    hanging.sprite.setAnimationSpeed(0.25);
    addState(hanging);

    State passthrough = new State("passthrough", "graphics/assorted/Passthrough-block.gif", 1, 4);
    passthrough.sprite.setAnimationSpeed(0.25);
    passthrough.sprite.setLooping(false);
    // the passthrough state lasts for 96 frames
    passthrough.sprite.addPathPoint(0, 0, 1, 1, 0, 96);
    addState(passthrough);

    setCurrentState("hanging");
  }

  /**
   * Test for sprite overlap, as well as boundary overlap
   */
  float[] overlap(Positionable other) {
    float[] overlap = super.overlap(other);
    if (overlap==null) {
      for (Boundary boundary: boundaries) {
        overlap = boundary.overlap(other);
        if (overlap!=null) return overlap;
      }
    }
    return null;
  }

  /**
   * Are we triggered? If so, and we're not in pass-through
   * state, we switch to pass-through state and stop being
   * interactive until the state finishes.
   */
  void overlapOccurredWith(Actor other, float[] overlap) {
    // stop actor movement if we're not in passthrough state
    if (active.name!="passthrough") {

      // Did we get spin-jumped on?
      if (other instanceof Mario && ((Mario)other).active.name=="spinning") {
        removeActor();
        return;
      }

      // We did not. See if we should become pass-through.
      other.rewindPartial();
      other.ix=0;
      other.iy=0;
      float minv = 3*PI/2 - radians(45);
      float maxv = 3*PI/2 + radians(45);
      if (minv <=overlap[2] && overlap[2]<=maxv) {
        setCurrentState("passthrough");
        disableBoundaries();
      }
    }
  }

  /**
   * When the pass-through state is done, go back
   * to being a normal block. Until the next time
   * someone decides to hit us from below.
   */
  void handleStateFinished(State which) {
    if (which.name=="passthrough") {
      setCurrentState("hanging");
      enableBoundaries();
    }
  }
}


/***************************************
 *                                     *
 *              PICKUPS                *
 *                                     *
 ***************************************/


/**
 * All pickups in Mario may move, and if
 * they do, they will bounce when hitting
 * a clean boundary.
 */
class MarioPickup extends Pickup {
  MarioPickup(String name, String spritesheet, int rows, int columns, float x, float y, boolean visible) {
    super(name, spritesheet, rows, columns, x, y, visible);
  }
  void gotBlocked(Boundary b, float[] intersection) {
    if (intersection[0]-x==0 && intersection[1]-y==0) {
      fx = -fx;
      active.sprite.flipHorizontal();
    }
  }
}

/**
 * A regular coin
 */
class Coin extends MarioPickup {
  Coin(float x, float y) {
    super("Regular coin", "graphics/assorted/Regular-coin.gif", 1, 4, x, y, true);
    SoundManager.load(this, "audio/Coin.mp3");
  }
  void pickedUp() { 
    SoundManager.play(this);
  }
}

/**
 * A dragon coin!
 */
class DragonCoin extends MarioPickup {
  DragonCoin(float x, float y) {
    super("Dragon coin", "graphics/assorted/Dragon-coin.gif", 1, 10, x, y, true);
    SoundManager.load(this, "audio/Dragon coin.mp3");
  }
  void pickedUp() { 
    SoundManager.play(this);
  }
}

/**
 * A delicious powerup mushroom
 */
class Mushroom extends MarioPickup {
  Mushroom(float x, float y) {
    super("Mushroom", "graphics/assorted/Mushroom.gif", 1, 1, x, y, false);
    getState("Mushroom").sprite.align(CENTER, BOTTOM);
    // make mushroom gently slide to the right
    setImpulseCoefficients(0, 0);
    setForces(2, DOWN_FORCE);
    setAcceleration(0, ACCELERATION);
    updatePositioningInformation();
    SoundManager.load(this, "audio/Powerup.mp3");
    persistent = false;
  }
  void pickedUp() { 
    SoundManager.play(this);
  }
}

/**
 * The sought-after fire flower
 */
class Flower extends MarioPickup {
  Flower(float x, float y) {
    super("Flower", "graphics/assorted/Flower.gif", 1, 1, x, y, false);
    getState("Flower").sprite.align(CENTER, BOTTOM);
    SoundManager.load(this, "audio/Powerup.mp3");
    persistent = false;
  }
  void pickedUp() { 
    SoundManager.play(this);
  }
  // most pickups bounce around. Fire flowers don't
  void gotBlocked(Boundary b, float[] intersection) {}
}

/**
 * A fire blob from fire mario.
 * This pickup is interesting because
 * it's a pickup for "not the player".
 */
class FireBlob extends MarioPickup {
  FireBlob(float x, float y, float ix, float iy) {
    super("Fire blob", "graphics/assorted/Flowerpower.gif", 1, 4, x, y, true);
    setImpulse(ix, iy);
    setImpulseCoefficients(1, 1);
    persistent = false;
    // note: no audio when picked up
  }

  // fire blobs disappear when they hit the ground
  void gotBlocked(Boundary b, float[] intersection) {
    removeActor();
  }
}

/**
 * The finish line is also a pickup,
 * and will trigger the "clear" state
 * for the level when picked up.
 */
class Rope extends MarioPickup {
  Rope(float x, float y) {
    super("Finish line", "graphics/assorted/Goal-slider.gif", 1, 1, x, y, true);
    Sprite s = getState("Finish line").sprite;
    s.align(LEFT, CENTER);
    s.setNoRotation(true);
    s.addPathLine(0, 0, 1, 1, 0, 0, -116, 1, 1, 0, 50);
    s.addPathLine(0, -116, 1, 1, 0, 0, 0, 1, 1, 0, 50);
    SoundManager.load(this, "audio/bg/Course-clear.mp3");
  }

  void pickedUp() {
    SoundManager.play(this);
    level.finish();
  }
}


/***************************************
 *                                     *
 *          SPECIAL BOUNDARIES         *
 *                                     *
 ***************************************/


/**
 * Removable boundary for pipes
 */
class PipeBoundary extends Boundary {
  // wrapper constructor
  PipeBoundary(float x1, float y1, float x2, float y2) {
    super(x1, y1, x2, y2);
    SoundManager.load(this, "audio/Pipe.mp3");
  }
  // used to effect "teleporting" incombination with the tube trigger
  void teleport() {
    disable();
    SoundManager.play(this);
  }
}


/***************************************
 *                                     *
 *             TRIGGERS                *
 *                                     *
 ***************************************/


/**
 * triggers a mushroom
 */
class PowerupTrigger extends Trigger {
  PowerupTrigger(float x, float y, float w, float h) {
    super("powerup", x, y, w, h);
  }
  void run(LevelLayer layer, Actor actor, float[] intersection) {
    Mushroom m = new Mushroom(452, 432-49);
    m.setImpulse(0.3, 0);
    layer.addForPlayerOnly(m);
    // remove this trigger so that it's not repeated
    removeTrigger();
  }
}

/**
 * triggers a koopa trooper 350px to the right
 */
class KoopaTrigger extends Trigger {
  float kx, ky, fx, fy;
  KoopaTrigger(float x, float y, float w, float h, float kx, float ky, float fx, float fy) {
    super("koopa", x, y, w, h);
    this.kx = kx;
    this.ky = ky;
    this.fx = fx;
    this.fy = fy;
  }
  void run(LevelLayer layer, Actor actor, float[] intersection) {
    Koopa k = new Koopa(x+kx, ky);
    k.setForces(fx, fy);
    if (fx>0) { 
      k.active.sprite.flipHorizontal();
    }
    k.persistent = false;
    layer.addInteractor(k);
    // remove this trigger so that it's not repeated
    removeTrigger();
  }
}

/**
 * triggers a koopa trooper on top of the slant
 */
class SlantKoopaTrigger extends Trigger {
  SlantKoopaTrigger(float x, float y, float w, float h) {
    super("slant koopa", x, y, w, h);
  }
  void run(LevelLayer layer, Actor actor, float[] intersection) {
    // this puts a slant-koopa at a very specific
    // location, namely on top of the slanted ground.
    Koopa k = new Koopa(296, 288);
    k.addForces(-0.2, 0);
    k.persistent = false;
    layer.addInteractor(k);
    // remove this trigger so that it's not repeated
    removeTrigger();
  }
}

/**
 * triggers a Banzai Bill!
 */
class BanzaiBillTrigger extends Trigger {
  float kx, ky, fx, fy;
  BanzaiBillTrigger(float x, float y, float w, float h, float kx, float ky, float fx, float fy) {
    super("banzai bill", x, y, w, h);
    this.kx = kx;
    this.ky = ky;
    this.fx = fx;
    this.fy = fy;
  }
  void run(LevelLayer layer, Actor actor, float[] intersection) {
    BanzaiBill k = new BanzaiBill(x+kx, ky);
    k.setImpulse(fx, fy);
    k.persistent = false;
    layer.addInteractor(k);
    // remove this trigger so that it's not repeated
    removeTrigger();
  }
}

/**
 * Tube trigger
 */
class TeleportTrigger extends Trigger {
  float tx, ty;
  Boundary lid;
  TeleportTrigger(float x, float y, float w, float h, float tx, float ty) {
    super("teleporter", x, y, w, h);
    this.tx = tx;
    this.ty = ty;
  }
  void setLid(Boundary lid) { 
    this.lid = lid;
  }
  void run(LevelLayer layer, Actor actor, float[] intersection) {
    // spit mario back out
    actor.setPosition(tx, ty);
    actor.setImpulse(0, 0);
    lid.enable();
  }
}

/**
 * Tube trigger
 */
class LayerTeleportTrigger extends TeleportTrigger {
  String target;
  LayerTeleportTrigger(float x, float y, float w, float h, float tx, float ty, String target) {
    super(x, y, w, h, tx, ty);
    this.target = target;
  }
  void run(LevelLayer layer, Actor actor, float[] intersection) {
    layer.removePlayer((Player)actor);
    level.getLevelLayer(target).addPlayer((Player)actor);
    actor.setPosition(tx, ty);
    actor.setImpulse(0, 0);
    lid.enable();
  }
}

/**
 * Tube trigger, with the target tube pointing upward
 */
class LayerTeleportTriggerUp extends TeleportTrigger {
  String target;
  LayerTeleportTriggerUp(float x, float y, float w, float h, float tx, float ty, String target) {
    super(x, y, w, h, tx, ty);
    this.target = target;
  }
  void run(LevelLayer layer, Actor actor, float[] intersection) {
    layer.removePlayer((Player)actor);
    level.getLevelLayer(target).addPlayer((Player)actor);
    actor.setPosition(tx, ty+24);
    actor.setImpulse(0, -20);
    lid.enable();
  }
}


/***************************************
 *                                     *
 *        LEVEL TELEPORTERS            *
 *                                     *
 ***************************************/


/**
 * to the dark bonus level
 */
class BonusLevelTrigger extends TeleportTrigger {
  BonusLevelTrigger(float x, float y, float w, float h, float tx, float ty) { 
    super(x, y, w, h, tx, ty);
  }
  void run(LevelLayer layer, Actor actor, float[] intersection) {
    // make sure mario's in the right place
    actor.setPosition(16, darkLevel.height-32);
    actor.setImpulse(0, -24);
    // switch to bonus level
    setLevel(darkLevel);
    // seal tube
    lid.enable();
  }
}

/**
 * back to main level 
 */
class MainLevelTrigger extends TeleportTrigger {
  MainLevelTrigger(float x, float y, float w, float h, float tx, float ty) { 
    super(x, y, w, h, tx, ty);
  }
  void run(LevelLayer layer, Actor actor, float[] intersection) {
    // make sure mario's in the right place
    actor.setPosition(tx, ty);
    // switch back to main level
    setLevel(mainLevel);
    // seal tube
    lid.enable();
  }
}


/***************************************
 *                                     *
 *              DECALS                 *
 *                                     *
 ***************************************/


/**
 * Uses the Decal class to show points
 * earned for jumping on enemies.
 */
class HitPoints extends Decal {
  // create a points text
  HitPoints(float x, float y, int points) {
    super("graphics/decals/"+points+".gif", x, y-16, 12);
  }
  // path: straight up, 64 pixels
  void setPath() {
    addPathLine(0, 0, 1, 1, 0, 
    0, 32, 1, 1, 0, 
    duration);
  }
}

