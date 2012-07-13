/**
 * This lets us define enemies as being part of
 * some universal class of things, as opposed to
 * non enemy NPCs (like yoshis or toadstools)
 */

abstract class MarioEnemy extends Interactor {
  MarioEnemy(String name) { super(name); } 
  MarioEnemy(String name, float x, float y) { super(name, x, y); } 
}

abstract class BoundedMarioEnemy extends BoundedInteractor {
  BoundedMarioEnemy(String name) { super(name); } 
  BoundedMarioEnemy(String name, float x, float y) { super(name, x, y); } 
}


/***
 * Enemies: koopa, banzai bill, muncher, bonus target
 ***/
/***************************************
 *                                     *
 *      INTERACTORS: BANZAI BILL       *
 *                                     *
 ***************************************/


/**
 * The big bullet that comes out of nowhere O_O
 */
class BanzaiBill extends MarioEnemy {

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
    // Banzai Bills do not care about boundaries or NPCs!
    setPlayerInteractionOnly(true);
    persistent = false;
  }

  /**
   * Banzai bill flies with great purpose.
   */
  void setupStates() {
    State flying = new State("flying", "graphics/enemies/Banzai-bill.gif");
    SoundManager.load(flying, "audio/Banzai.mp3");
    addState(flying);
    setCurrentState("flying");
    SoundManager.play(flying);
  }

  /**
   * What happens when we touch another actor?
   */
  void overlapOccurredWith(Actor other, float[] direction) {
    if (other instanceof Mario) {
      Mario m = (Mario) other;
      m.hit();
    }
  }
  
  /**
   * Nothing happens at the moment
   */
  void hit() {}
}
class BonusTarget extends MarioEnemy {
  
  ArrayList<HitListener> listeners = new ArrayList<HitListener>();
  void addListener(HitListener l) { if (!listeners.contains(l)) { listeners.add(l); }}
  void removeListener(HitListener l) { listeners.remove(l); }  
  
  float radial = 40;
  
  BonusTarget(float x, float y, float r) {
    super("Bonus Target");
    setPosition(x,y);
    radial = r;
    setupStates();
  }

  void setupStates() {
    State swirl = new State("swirl","graphics/assorted/Target.gif", 1, 4);
    // Set up a circle path using bezier curves.
    // Each curve segment lasts 15 frames.
    float d = radial, k = 0.55 * d;
    swirl.addPathCurve(0,-d,   k,-d,   d,-k,   d,0,  15,1);
    swirl.addPathCurve(d,0,     d,k,    k,d,   0,d,  15,1);
    swirl.addPathCurve(0,d,    -k,d,   -d,k,  -d,0,  15,1);
    swirl.addPathCurve(-d,0,  -d,-k,  -k,-d,  0,-d,  15,1);
    swirl.setLooping(true);
    swirl.setAnimationSpeed(0.5);
    addState(swirl);

    SoundManager.load("target hit", "audio/Squish.mp3");
    SoundManager.load("pipe appears", "audio/Powerup.mp3");
  }

  void setPathOffset(int offset) {
    getState("swirl").sprite.setPathOffset(offset);
  }

  // when a target is hit, we want to tell our bonus level about that.
  void pickedUp(Pickup pickup) {
    SoundManager.play("target hit");
    for(HitListener l: listeners) {
      l.targetHit();
    }
  }

  /**
   * What happens when we touch another actor?
   */
  void overlapOccurredWith(Actor other, float[] direction) {
    if (other instanceof Mario) {
      Mario m = (Mario) other;
      m.hit();
    }
  }
}

/**
 * necessary for counting targets shot down
 */
interface HitListener { void targetHit(); }
/**
 * Our main enemy
 */
class Koopa extends MarioEnemy {

  Koopa(float x, float y) {
    super("Koopa Trooper");
    setStates();
    setForces(-0.25, DOWN_FORCE);    
    setImpulseCoefficients(DAMPENING, DAMPENING);
    setPosition(x,y);
  }
  
  /**
   * Set up our states
   */
  void setStates() {
    // walking state
    State walking = new State("idle", "graphics/enemies/Red-koopa-walking.gif", 1, 2);
    walking.setAnimationSpeed(0.12);
    SoundManager.load(walking, "audio/Squish.mp3");
    addState(walking);
    
    // if we get squished, we first get naked...
    State naked = new State("naked", "graphics/enemies/Naked-koopa-walking.gif", 1, 2);
    naked.setAnimationSpeed(0.12);
    SoundManager.load(naked, "audio/Squish.mp3");
    addState(naked);
    
    setCurrentState("idle");
  }
  
  /**
   * when we hit a vertical wall, we want our
   * koopa to reverse direction
   */
  void gotBlocked(Boundary b, float[] intersection, float[] original) {
    if (b.x==b.xw) {
      ix = -ix;
      fx = -fx;
      setHorizontalFlip(fx > 0);
    }
  }
  
  void hit() {
    SoundManager.play(active);

    // do we have our shell? Then we only get half-squished.
    if (active.name != "naked") {
      setCurrentState("naked");
      return;
    }
    
    // no shell... this koopa is toast.
    removeActor();
  }
}
/**
 * The muncher plant. To touch it is to lose.
 */
class Muncher extends BoundedMarioEnemy {

  Muncher(float x, float y) {
    super("Muncher");
    setPosition(x,y);
    setupStates();
    addBoundary(new Boundary(x-width/2,y+2-height/2,x+width/2,y+2-height/2), true);
  }

  void setupStates() {
    State munch = new State("munch","graphics/enemies/Muncher.gif", 1, 2);
    munch.setAnimationSpeed(0.20);
    addState(munch);
  }

  void collisionOccured(Boundary boundary, Actor other, float[] correction) {
    if (other instanceof Mario) {
      ((Mario)other).hit();
    }
  }
}
/**
 * Our dapper hero
 */
class Mario extends Player {

  int score = 0;
  float speed = 2.5;
  boolean canShoot = false;
  String spriteSet = "mario";
  String type = "small";
  
  /**
   * Mario can carry keys! It's magical!
   */
  Decal key = null;
  boolean hasKey = false; 
  void getKey() { hasKey = true; key = new KeyDecal(width,0); addDecal(key); }
  void removeKey() { hasKey = false; removeDecal(key); }

  Mario() {
    super("Mario");
    setupStates(spriteSet, type);
    setCurrentState("idle");
    // input handling
    handleKey('W');
    handleKey('A');
    handleKey('S');
    handleKey('D');
    // forces that act on Mario
    setImpulseCoefficients(DAMPENING, DAMPENING);
    setForces(0, DOWN_FORCE);
    setAcceleration(0, ACCELERATION);
  }

  void setSpriteSet(String setName) {
    spriteSet = setName;
    setupStates(spriteSet,type);
  }

  void setSpriteType(String typeName) {
    type = typeName;
    setupStates(spriteSet,type);
  }
  
  // make sure all states are center/bottom anchored
  void addState(State st) {
    st.sprite.anchor(CENTER, BOTTOM);
    super.addState(st);
  }

  /**
   * Set up our states
   */
  void setupStates(String spriteSet, String type) {
    // idling state
    addState(new State("idle", "graphics/"+spriteSet+"/"+type+"/Standing-mario.gif"));

    // crouching state
    addState(new State("crouching", "graphics/"+spriteSet+"/"+type+"/Crouching-mario.gif"));

    // running state
    addState(new State("running", "graphics/"+spriteSet+"/"+type+"/Running-mario.gif", 1, 4));

    // dead state O_O
    if(type == "small") {
      State dead = new State("dead", "graphics/"+spriteSet+"/"+type+"/Dead-mario.gif", 1, 2);
      dead.setAnimationSpeed(0.25);
      dead.setDuration(100);
      addState(dead);   
      SoundManager.load(dead, "audio/Dead mario.mp3");
    }

    // jumping state
    State jumping = new State("jumping", "graphics/"+spriteSet+"/"+type+"/Jumping-mario.gif");
    jumping.setDuration(15);
    addState(jumping);
    SoundManager.load(jumping, "audio/Jump.mp3");

    // crouchjumping state
    State crouchjumping = new State("crouchjumping", "graphics/"+spriteSet+"/"+type+"/Crouching-mario.gif");
    crouchjumping.setDuration(15);
    addState(crouchjumping);
    SoundManager.load(crouchjumping, "audio/Jump.mp3");

    // victorious state!
    State won = new State("won", "graphics/"+spriteSet+"/"+type+"/Standing-mario.gif");
    won.setDuration(240);
    addState(won);
    
    // being hit requires a sound effect too
    SoundManager.load("mario hit", "audio/Pipe.mp3");
  }

  /**
   * Handle input
   */
  void handleInput() {
    if (spriteSet == "mario") {
      handleMarioInput();
    }
  }

  void handleMarioInput() {
    // we don't handle any input when we're dead~
    if (active.name=="dead" || active.name=="won") return;

    // what do we "do"? (i.e. movement wise)
    if (active.name!="crouching" && (isKeyDown('A') || isKeyDown('D'))) {
      if (isKeyDown('A')) {
        // when we walk left, we need to flip the sprite
        setHorizontalFlip(true);
        // walking left means we get a negative impulse along the x-axis:
        addImpulse(-speed, 0);
        // and we set the viewing direction to "left"
        setViewDirection(-1, 0);
      }
      if (isKeyDown('D')) {
        // when we walk right, we need to NOT flip the sprite =)
        setHorizontalFlip(false);
        // walking right means we get a positive impulse along the x-axis:
        addImpulse(speed, 0);
        // and we set the viewing direction to "right"
        setViewDirection(1, 0);
      }
    }

    // if the jump key is pressed, and we're standing on something, let's jump! 
    if (active.mayChange() && isKeyDown('W') && boundaries.size()>0) {
      ignore('W');
      // generate a massive impulse upward
      addImpulse(0, -35);
      // and make sure we look like we're jumping, too
      if (active.name!="crouching") {
        setCurrentState("jumping");
      } else {
        setCurrentState("crouchjumping");
      }
      SoundManager.play(active);
    }

    // if we're not jumping, but left or right is pressed,
    // make sure we're using the "running" state.
    if (isKeyDown('S')) {
      if (boundaries.size()>0) {
        for(Boundary b: boundaries) {
          if(b instanceof PipeBoundary) {
            ((PipeBoundary)b).trigger(this);
          }
        }
      }
      if (active.name=="jumping") {
        setCurrentState("crouchjumping");
      } else {
        setCurrentState("crouching");
      }
    }

    // and what do we look like when we do this?
    if (active.mayChange())
    {
      if (active.name!="crouching" && (isKeyDown('A') || isKeyDown('D'))) {
       setCurrentState("running");
      }

      // if we're not actually doing anything,
      // then we change the state to "idle"
      else if (noKeysDown()) {
        setCurrentState("idle");
      }
    }
  }

  /**
   * When 'fixed frame count' animations end
   * such as the jump animation, what should we do?
   */
  void handleStateFinished(State which) {
    if (which.name == "dead" || which.name == "won") {
      removeActor();
      reset();
    } 
    else { setCurrentState("idle"); }
  }

  /**
   * What happens when we touch another actor?
   */
  void overlapOccurredWith(Actor other, float[] direction) {
    if (other instanceof MarioEnemy) {
      MarioEnemy enemy = (MarioEnemy) other;
      float angle = direction[2];

      // We bopped a koopa on the head!
      float tolerance = radians(75);
      if (PI/2 - tolerance <= angle && angle <= PI/2 + tolerance) {
        enemy.hit();
        stop(0, 0);
        setImpulse(0, -30);
        if (spriteSet == "mario") {
          setCurrentState("jumping");
        }
      }

      // Oh no! We missed and touched a koopa!
      else { hit(); }
    }
  }
  
  void hit() {
    if(isDisabled()) return; 
    if(type != "small") {
      setSpriteType("small");
      disableInteractionFor(30);
      SoundManager.play("mario hit");
      return;
    }
    // else:
    die();
  }

  /**
   * When we die, we need to go in the funky "oh no we lost~" dance dive.
   */
  void die() {
    setCurrentState("dead");
    setInteracting(false);
    setImpulse(0, -30);
    setForces(0, 3);
    // stop background music!
    SoundManager.stop(getLevelLayer().getLevel());
    // play sad music =(
    SoundManager.play(active);
  }

  /**
   * What happens when we get pickups?
   */
  void pickedUp(Pickup pickup) {
    // we got some points
    if (pickup.name=="Regular coin") {
      score++;
    }
    // we got big points
    else if (pickup.name=="Dragon coin") {
      score+=100;
    }
    // we won!
    else if (pickup.name=="Finish line") {
      if (spriteSet == "rtype") {
        setForces(0, DOWN_FORCE);
        setAcceleration(0, ACCELERATION);
      }
      spriteSet = "mario";
      Level level = layer.getLevel();
      setCurrentState("won");
      layer.parent.finish();
    }
    // big mario
    else if (pickup.name=="Mushroom") {
      setSpriteType("big");
      disableInteractionFor(30);
    }
    // fire mario
    else if (pickup.name=="Fire flower") {
      // we could effect a full sprite swap here
      canShoot = true;
      setSpriteType("fire");
    }
    // key?
    else if (pickup.name=="Key") {
      getKey();
    }
  }
  
  void mousePressed(int mx, int my, int mb) {
    if (canShoot) {
      if (spriteSet == "rtype") {
        shoot(20, 0);
      } 
      else {
        float[] mi = layer.getMouseInformation(getX(), getY(), mx, my);
        float speed = 10, 
        dx = mi[0], 
        dy = mi[1], 
        len = sqrt(dx*dx + dy*dy);
        dx/=len;
        dy/=len;
        shoot(speed*dx, speed*dy);
      }
    }
  }

  void shoot(float dx, float dy) {
    FireBlob fb = new FireBlob(getX(), getY());
    fb.addImpulse(dx, dy);
    layer.addForInteractorsOnly(fb);
  }
}

/**
 * Our main level layer has a background
 * color, and nothing else.
 */
class MainBackgroundLayer extends MarioLayer {
  Mario mario;
  MainBackgroundLayer(Level owner) {
    super(owner, owner.width, owner.height, 0,0, 0.75,0.75);
    addBackgroundSprite(new TilingSprite(new Sprite("graphics/backgrounds/sky_2.gif"),0,0,width,height));

    addBoundary(new Boundary(-1,0, -1,height));
    addBoundary(new Boundary(width+1,height, width+1,0));
    addGround("ground", 0,height-100, width,height-100+16);

    /*
    for (int x=0; x<width+1; x+=width/25) {
      int i = (int)round(x/(width/25));
      for (int y = (i%2==0? 0 : int(height/10)); y<height+1; y+=height/5) {
        addCoins(x,y,16);
      }
    }
    */
    
    addTube(304,height-100,null);
    int pos = 1914;
    addTube(pos,height-100,new LayerTeleportTrigger("main layer", 2020+16,32));
    
    addGoal(2060,height-100);
  }

  void draw() {
    background(color(0, 100, 190));
    super.draw();
  }
}
class BonusLayer extends MarioLayer implements HitListener {

  int target_count = 0;
  
  BonusLayer(Level parent) {
    super(parent);

    // repeating background sprite image
    Sprite bgsprite = new Sprite("graphics/backgrounds/nightsky_fg.gif");
    bgsprite.align(RIGHT, TOP);
    TilingSprite backdrop = new TilingSprite(bgsprite, 0, 0, width, height);
    addBackgroundSprite(backdrop);      

    // side walls
    addBoundary(new Boundary(-1,0, -1,height));
    addBoundary(new Boundary(width+1,height, width+1,0));
    
    // set up ground
    addGround("cave", 0, height-16, width, height);
  
    // generate a series of swirling targets
    int offset = 0;
    for (int y = 64; y<=height-96; y+=64) {
      for (int x = 64; x<=width-64; x+=96) {
        BonusTarget target = new BonusTarget(x, y, 30);
        target.setPathOffset(offset);
        target.addListener(this);
        addInteractor(target);
        offset += 12;
        target_count++;
      }
    }
    float w = 32, w2 = 2*w, w4 = w2*2, w8 = w4*2;
    addGroundPlatform("cave", width/2-w, height-64, w2, 48);
    addGroundPlatform("cave", width/2-w2, height-48, w4, 32);
    addGroundPlatform("cave", width/2-w4, height-32, w8, 16);
  }

  // when a target is hit, check if they're all dead. if so, pop up an exit pipe!
  void targetHit() {
    target_count--;
    if(target_count==0) {
      addTube(width/2-16, height-64, new LevelTeleportTrigger("Main Level",  width-30,height-34,30,2,  804+16,373));
    }
  }
  
}
class BonusBackgroundLayer extends MarioLayer{
  BonusBackgroundLayer(Level parent) {
    super(parent);
    // repeating background sprite image
    Sprite bgsprite = new Sprite("graphics/backgrounds/nightsky_bg.gif");
    bgsprite.align(RIGHT, TOP);
    TilingSprite backdrop = new TilingSprite(bgsprite, 0, 0, width, height);
    addBackgroundSprite(backdrop); 
  }
}
/**
 * Plain color background layer
 */
class BackgroundColorLayer extends LevelLayer {
  BackgroundColorLayer(Level parent, color c) {
    super(parent, parent.width, parent.height);
    backgroundColor = c;
  }
}
class DarkLevelLayer extends MarioLayer implements UnlockListener {
  KeyHole keyhole;
  
  DarkLevelLayer(Level parent) {
    super(parent);

    // repeating background sprite image
    Sprite bgsprite = new Sprite("graphics/backgrounds/bonus.gif");
    bgsprite.align(RIGHT, TOP);
    TilingSprite backdrop = new TilingSprite(bgsprite, 0, 0, width, height);
    addBackgroundSprite(backdrop);      

    // side walls
    addBoundary(new Boundary(-1,0, -1,height));
    addBoundary(new Boundary(width+1,height, width+1,0));
    
    // set up ground
    addGround("cave", 0, height-16, width, height);
    addUpsideDownGround("cave", 0, 0, width, 16);

    float x, y, wth;
    for (int i=1; i<=4; i++) {
      x = i*56;
      y = height-i*48;
      wth = width-2*i*56;
      addGroundPlatform("cave", x, y-16, wth, 48);
      addCoins(x, y-40, wth);
    }

    // flower power
    addBoundedInteractor(new FlowerBlock(width/2,height/2-64));

    // set up the tubes
    addTube(0, height-16, null);
    addTube(width-32, height-16, new LevelTeleportTrigger("Main Level",  width-30,height-34,30,2,  804+16,373));

    // conspicuous keyhole...
    keyhole = addKeyHole(width/2, height-28);
    keyhole.addListener(this);
  }
  
  /**
   * the bonus content was unlocked!
   */
  void unlocked(Actor by, KeyHole hole) {
    removeKeyHole(keyhole);
    // switch to bonus level
    Player p = ((MarioLevel)activeScreen).mario;
    setActiveScreen("Bonus Level");
    MarioLevel a = (MarioLevel) activeScreen;
    a.updateMario(p);
  }
  
  void mousePressed() {
    unlocked(null,null);
  }
}
/**
 * Our main level layer has a background
 * color, and nothing else.
 */
class MainLevelLayer extends MarioLayer {
 
  MainLevelLayer(Level owner) {
    super(owner);
    //setBackgroundColor(color(0,130,255));
    addBackgroundSprite(new TilingSprite(new Sprite("graphics/backgrounds/sky.gif"),0,0,width,height));

    // we don't want mario to walk off the level,
    // so let's add some side walls
    addBoundary(new Boundary(-1,0, -1,height));
    addBoundary(new Boundary(width+1,height, width+1,0));

//    addGround("ground", -32,height-48, width + 32,height);

    // add general ground, with a muncher pit
    float gap = 58;
    addGround("ground", -32,height-48, -32 + gap*32,height);
    addBoundary(new Boundary(-32 + gap*32,height-47,-32 + gap*32,height));
    for(int i=0; i<4; i++) { addBoundedInteractor(new Muncher(-32 + (gap*32) + 8 + (16*i),height-8)); }
    gap += 2;
    addBoundary(new Boundary(-31 + gap*32,height,-31 + gap*32,height-47));
    addGround("ground", -31 + gap*32,height-48, width+32,height);


    // add decorative foreground bushes
    addBushes();
    
    // add a few slanted hills
    addSlant(256, height-48);
    addSlant(1300, height-48);
    addSlant(1350, height-48);

    // add some ground platforms    
    addGroundPlatform("ground", 928, height-224, 96, 112);
    addCoins(928,height-236,96);
    addGroundPlatform("ground", 920, height-176, 32, 64);
    addGroundPlatform("ground", 912, height-128, 128, 80);
    addCoins(912,height-140,128);
    addGroundPlatform("ground", 976, height-96, 128, 48);
    addGroundPlatform("ground", 1442, height-128, 128, 80);
    addCoins(1442,height-140,128);
    addGroundPlatform("ground", 1442+64, height-96, 128, 48);

    for(int i=0; i<7; i++) {
      addBoundedInteractor(new CoinBlock(1158+i*16,height-128));
    }

    // mystery coins
    addForPlayerOnly(new DragonCoin(352,height-164));

    // Let's also add a koopa on one of the slides
    Koopa koopa = new Koopa(264, height-178);
    addInteractor(koopa);

    // add lots of just-in-time triggers
    addTriggers();
    
    // add some tubes
    addTubes();

    // layer of skyblocks
    for(int i=0; i<24; i++) {
      addBoundedInteractor(new SkyBlock(width-23.5*16+i*16,96));
    }

    // key!
    addForPlayerOnly(new KeyPickup(2000,364));
  }

  // In order to effect "just-in-time" sprite placement,
  // we set up some trigger regions.
  void addTriggers() {
    // initial hidden mushroom
    addTrigger(new MushroomTrigger(148,370,5,12, 406,373.9, 2, 0));
    // koopas
    addTrigger(new KoopaTrigger(412,0,5,height, 350, height-64, -0.2, 0));
    addTrigger(new KoopaTrigger(562,0,5,height, 350, height-64, -0.2, 0));
    addTrigger(new KoopaTrigger(916,0,5,height, 350, height-64, -0.2, 0));
    // when tripped, release a banzai bill!
    addTrigger(new BanzaiBillTrigger(1446,310,5,74, 400, height-95, -6, 0));
  }
  
  // some tubes for transport
  void addTubes() {
    // tube transport
    addTube(660,height-48, new LayerTeleportTrigger("background layer",  304+16,height/0.75-116));
    addTube(804,height-48, null);

    // placed on sky blocks
    addTube(width-8-23.5*16,88,  new LevelTeleportTrigger("Dark Level",  2020+6,height-65,16,1,  16, height-32));
    addUpsideDownTube(2020,0);
  }
}
/**
 * Bonus!
 */
class BonusLevel extends MarioLevel
{
  BonusLevel(float w, float h)
  {
    super(w, h);
    addLevelLayer("Background Layer", new BackgroundColorLayer(this, color(24,48,72)));
    addLevelLayer("Star Layer", new BonusBackgroundLayer(this));

    LevelLayer layer = new BonusLayer(this);
    addLevelLayer("Bonus Layer", layer);
    mario.setPosition(width/2, height-32);
    layer.addPlayer(mario);

    SoundManager.load(this, "audio/bg/Bonus.mp3");
  }
  
  void updateMario(Player p) {
    super.updateMario(p);
    mario.setPosition(width/2, height-32);
  }
}
/**
 * To show level swapping we also have a small "dark"
 * level that is teleport from, and back out of.
 */
class DarkLevel extends MarioLevel
{
  // constructor sets up a level and level layer
  DarkLevel(float w, float h)
  {
    super(w, h);
    addLevelLayer("color", new BackgroundColorLayer(this, color(0, 0, 100)));

    LevelLayer layer = new DarkLevelLayer(this);
    addLevelLayer("main", layer);
    mario.setPosition(16,height-80);
    layer.addPlayer(mario);

    // And of course some background music.
    SoundManager.load(this, "audio/bg/Bonus.mp3");
  }
}
/**
 * Our "empty" level is a single layer
 * level, doing absolutely nothing.
 */
class MainLevel extends MarioLevel {
  MainLevel(float levelWidth, float levelHeight) {
    super(levelWidth, levelHeight);

    // background
    addLevelLayer("background layer", new MainBackgroundLayer(this));

    // main level layer
    LevelLayer layer = new MainLevelLayer(this);
    addLevelLayer("main layer", layer);
    mario.setPosition(16, height-64);
    layer.addPlayer(mario);

    // And of course some background music!
    SoundManager.load(this, "audio/bg/Overworld.mp3");
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
 * We must set the screen dimensions to something
 */
final int BLOCK = 16,
          screenWidth = 32*BLOCK,
          screenHeight = 27*BLOCK;

/**
 * Gravity consists of a uniform downforce,
 * and a gravitational acceleration
 */
float DOWN_FORCE = 2;
float ACCELERATION = 1.3;
float DAMPENING = 0.75;


/**
 * initializing means building an "empty"
 * level, which we'll 
 */
void initialize() {
  SoundManager.mute(true);
  SoundManager.setDrawPosition(screenWidth-32,16);
  frameRate(30);
  reset();
}

void reset() {
  clearScreens();
  addScreen("Bonus Level", new BonusLevel(width, height));
  addScreen("Dark Level", new DarkLevel(width, height));
  addScreen("Main Level", new MainLevel(4*width, height));  
  if(javascript != null) { javascript.reset(); }
  setActiveScreen("Main Level");
}

class MarioLayer extends LevelLayer {

  // constructor
  MarioLayer(Level owner) {
    this(owner, owner.width, owner.height, 0,0,1,1);
  }
  
  MarioLayer(Level owner, float w, float h, float ox, float oy, float sx, float sy) {
    super(owner,w,h,ox,oy,sx,sy);
    //showBoundaries = true;
    //showTriggers = true;
  }
  
  /**
   * Add some ground.
   */
  void addGround(String tileset, float x1, float y1, float x2, float y2) {
    TilingSprite groundline = new TilingSprite(new Sprite("graphics/backgrounds/"+tileset+"-top.gif"), x1,y1,x2,y1+16);
    addBackgroundSprite(groundline);
    TilingSprite groundfiller = new TilingSprite(new Sprite("graphics/backgrounds/"+tileset+"-filler.gif"), x1,y1+16,x2,y2);
    addBackgroundSprite(groundfiller);
    addBoundary(new Boundary(x1,y1,x2,y1));
  }
  
  /**
   * Add some upside down ground
   */
  void addUpsideDownGround(String tileset, float x1, float y1, float x2, float y2) {
    TilingSprite groundfiller = new TilingSprite(new Sprite("graphics/backgrounds/"+tileset+"-filler.gif"), x1,y1,x2,y2-16);
    addBackgroundSprite(groundfiller);
    Sprite topLayer = new Sprite("graphics/backgrounds/"+tileset+"-top.gif");
    topLayer.flipVertical();
    topLayer.flipHorizontal();
    TilingSprite groundline = new TilingSprite(topLayer, x1,y2-16,x2,y2);
    addBackgroundSprite(groundline);
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
    addBackgroundSprite(groundslant);
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
      addForegroundSprite(sprite);
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
      addForegroundSprite(sprite);
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
      addForegroundSprite(sprite);
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
      addForegroundSprite(sprite);
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

    addBackgroundSprite(lc);
    addBackgroundSprite(toprow);
    addBackgroundSprite(rc);

    // sides/filler
    TilingSprite sideleft  = new TilingSprite(new Sprite("graphics/backgrounds/"+tileset+"-side-left.gif"),  x,            y+tp.height, x+lc.width,     y+h);
    TilingSprite filler    = new TilingSprite(new Sprite("graphics/backgrounds/"+tileset+"-filler.gif"),     x+lc.width,   y+tp.height, x+(w-rc.width), y+h);
    TilingSprite sideright = new TilingSprite(new Sprite("graphics/backgrounds/"+tileset+"-side-right.gif"), x+w-rc.width, y+tp.height, x+w,            y+h);

    addBackgroundSprite(sideleft);
    addBackgroundSprite(filler);
    addBackgroundSprite(sideright);

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
    addBackgroundSprite(goal_b);
    // foreground post
    Sprite goal_f = new Sprite("graphics/assorted/Goal-front.gif");
    goal_f.align(CENTER, BOTTOM);
    goal_f.setPosition(xpos+32, hpos);
    addForegroundSprite(goal_f);
    // the finish line rope
    addForPlayerOnly(new Rope(xpos, hpos-16));
  }

  // places a single tube with all the boundaries and behaviours
  void addTube(float x, float y, TeleportTrigger teleporter) {
    // pipe head as foreground, so we can disappear behind it.
    Sprite pipe_head = new Sprite("graphics/assorted/Pipe-head.gif");
    pipe_head.align(LEFT, BOTTOM);
    pipe_head.setPosition(x, y-16);
    addForegroundSprite(pipe_head);

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
    addBackgroundSprite(pipe);

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
    addBoundary(new Boundary(x+32, y-16-32, x+32, y));
    addBoundary(new Boundary(x+32, y, x, y));
    addBoundary(new Boundary(x, y, x, y-16-32));
    
  }
  
  // places a single tube with all the boundaries and behaviours, upside down
  void addUpsideDownTube(float x, float y) {
    // pipe body as background
    Sprite pipe = new Sprite("graphics/assorted/Pipe-body.gif");
    pipe.align(LEFT, TOP);
    pipe.setPosition(x, y);
    addBackgroundSprite(pipe);

    // pipe head as foreground, so we can disappear behind it.
    Sprite pipe_head = new Sprite("graphics/assorted/Pipe-head.gif");
    pipe_head.align(LEFT, TOP);
    pipe_head.flipVertical();
    pipe_head.setPosition(x, y+16);
    addForegroundSprite(pipe_head);

    // And add side-walls and the bottom "lid.
    addBoundary(new Boundary(x, y+16+32, x, y));
    addBoundary(new Boundary(x+32, y, x+32, y+16+32));

    addBoundary(new Boundary(x+32, y+16+32, x, y+16+32));
  }

  // keyhole
  KeyHole addKeyHole(float x, float y) {
    KeyHole k = new KeyHole(x,y);
    addInteractor(k);
    return k;
  }
  
  void removeKeyHole(KeyHole k) {
    removeInteractor(k);
  }
}
/**
 * a level in a mario game
 */
class MarioLevel extends Level {
  Player mario;
  String wintext = "Goal!";
  int endCount = 0;

  MarioLevel(float w, float h) { 
    super(w, h);
    textFont(createFont("fonts/acmesa.ttf", 8));
    setViewBox(0,0,screenWidth,screenHeight);
    mario = new Mario();    
  }
  
  void updateMario(Player mario_new) {
    updatePlayer(mario, mario_new);
    mario = mario_new;
  }

  /**
   * Now then, the draw loop: render mario in
   * glorious canvas definition.
   */
  void draw() {
    if (!finished) {
      super.draw();
      viewbox.track(this, mario);
      // just to be sure
      if(mario.active!=null && mario.active.name!="dead" && (mario.x<-200 || mario.x>mario.layer.width+200 || mario.y<-200 || mario.y>mario.layer.height+200)) {
        reset();
        return;
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
      rect(-1, -1, width+2, height+2);
      if (endCount>7.5*frameRate) {
        SoundManager.stop(this);
        reset();
      }
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
  // default horizontal bounce
  void gotBlocked(Boundary b, float[] intersection, float[] original) {
    if (b.x==b.xw) {
      ix = -original[0];
      fx = -fx;
      active.sprite.flipHorizontal();
      detachFrom(b);
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
 * A mushroom powerup
 */
class Mushroom extends MarioPickup {
  Mushroom(float x, float y) {
    super("Mushroom", "graphics/assorted/Mushroom.gif", 1, 1, x, y, true);
    SoundManager.load(this, "audio/Powerup.mp3");
    setAcceleration(0,0);
  }
  void pickedUp() { 
    SoundManager.play(this);
  }
}

/**
 * A fire flower powerup
 */
class FireFlower extends MarioPickup {
  FireFlower(float x, float y) {
    super("Fire flower", "graphics/assorted/Flower.gif", 1, 1, x, y, true);
    SoundManager.load(this, "audio/Powerup.mp3");
  }
  void pickedUp() { 
    SoundManager.play(this);
  }
}

/**
 * A fire blob
 */
class FireBlob extends MarioPickup {
  FireBlob(float x, float y) {
    super("Fire blob", "graphics/assorted/Flowerpower.gif", 1, 4, x, y, false);
    SoundManager.load(this, "audio/Squish.mp3");
    persistent = false;
  }
  void pickedUp() { 
    SoundManager.play(this);
  }
  void overlapOccurredWith(Actor other) {
    super.overlapOccurredWith(other);
    other.removeActor();
  }
  void gotBlocked(Boundary b, float[] intersection, float[] original) {
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
    State st = getState("Finish line");
    st.addPathLine(0, 0,     0, -116, 50);
    st.addPathLine(0, -116,  0, 0,    50);
    st.setLooping(true);
    Sprite spr = st.sprite;
    spr.align(LEFT, TOP);
    spr.setNoRotation(true);
    SoundManager.load(this, "audio/bg/Course-clear.mp3");
  }

  void pickedUp() {
    // stop background music!
    SoundManager.stop(getLevelLayer().getLevel());
    // play victory music!
    SoundManager.play(this);
  }
}
/**
 * blocks are interactors (NPCs) that are
 * fixed in place by default, and generate
 * a "something" when hit from the right
 * direction.
 */
abstract class MarioBlock extends BoundedInteractor {

  // how many "somethings" can be generated?
  int content = 1;

  MarioBlock(String name, float x, float y) {
    super(name);
    setPosition(x, y);
    setupStates();
    setupBoundaries();
  }

  void setupStates() {
    State hanging = new State("hanging", "graphics/assorted/Coin-block.gif", 1, 4);
    hanging.setAnimationSpeed(0.2);
    addState(hanging);

    State exhausted = new State("exhausted", "graphics/assorted/Coin-block-exhausted.gif");
    addState(exhausted);

    setCurrentState("hanging");
  }

  void setupBoundaries() {
    float xa = (getX() - width/2),
          xb = (getX() + width/2)-1,
          ya = (getY() - height/2),
          yb = (getY() + height/2)-1;
    
    addBoundary(new Boundary(xa, yb-1, xa, ya+1));
    addBoundary(new Boundary(xa, ya, xb, ya));
    addBoundary(new Boundary(xb, ya+1, xb, yb-1));
    // the bottom boundary is special, because we want
    // to know whether things collide with it.
    addBoundary(new Boundary(xb, yb, xa, yb), true);
  }

  // generate something
  void collisionOccured(Boundary boundary, Actor other, float[] intersectionInformation) {
    // do nothing if we can't generate anything (anymore)
    if (content == 0) return;
    // otherwise, see if we need to generate something.
    if (other instanceof Player) {
      // generate a "something"
      generate(intersectionInformation);
      // we can also generate 1 fewer things now
      content--;
      if (content == 0) {
        // nothing left to generate: change state
        setCurrentState("exhausted");
      }
    }
  }

  // generate a "something". subclasses must implement this
  abstract void generate(float[] intersectionInformation);
}


/**
 * Coin block
 */
class CoinBlock extends MarioBlock {
  CoinBlock(float x, float y) {
    super("Coin block", x, y);
  }

  void generate(float[] intersectionInformation) {
    Coin c = new Coin(getX(), getY()-height/2);
    c.setImpulse(0, -10);
    c.setForces(0, DOWN_FORCE);
    c.setAcceleration(0, ACCELERATION);
    layer.addForPlayerOnly(c);
  }
}

/**
 * Sky block
 */
class SkyBlock extends MarioBlock {
  SkyBlock(float x, float y) {
    super("Sky block", x, y);
    addState(new State("hanging", "graphics/assorted/Sky-block.gif"));
    addState(new State("exhausted", "graphics/assorted/Sky-block.gif"));
  }
  void generate(float[] intersectionInformation) {}
}



/**
 * Mushroom block
 */
class MushroomBlock extends MarioBlock {
  float mushroom_speed = 0.7;
  
  MushroomBlock(float x, float y) {
    super("Mushroom block", x, y);
  }

  void generate(float[] intersectionInformation) {
    float angle = atan2(intersectionInformation[1],intersectionInformation[0]);
    Mushroom m = new Mushroom(getX(), getY()-height/2);
    m.setImpulse((angle<-1.5*PI ? -1:1) * mushroom_speed, -10);
    m.setImpulseCoefficients(0.75,0.75);
    m.setForces((angle<-1.5*PI ? 1:-1) * mushroom_speed, DOWN_FORCE);
    m.setAcceleration(0,0);
    layer.addForPlayerOnly(m);
  }
}


/**
 * Fireflow powerup block
 */
class FlowerBlock extends MarioBlock {
  FlowerBlock(float x, float y) { 
    super("Fireflower block", x, y);
  }

  void generate(float[] intersectionInformation) {
    FireFlower f = new FireFlower(getX(), getY()-height/2);
    f.setImpulse(0, -10);
    f.setForces(0, DOWN_FORCE);
    f.setAcceleration(0, ACCELERATION);
    layer.addForPlayerOnly(f);
  }
}

// Keys are handled in two parts - a pickup, which when picked up effects a decal //

/**
 * The decal part of keys
 */
class KeyDecal extends Decal {
  KeyDecal(float x, float y) {
    super("graphics/assorted/Key.gif",x,y);
  }
}

/**
 * The pickup part of keys
 */
class KeyPickup extends MarioPickup {
  KeyPickup(float x, float y) {
    super("Key", "graphics/assorted/Key.gif", 1, 1, x, y, true);
    setForces(0,DOWN_FORCE);
    setAcceleration(0,ACCELERATION);
  }
}


/**
 * The keyhole is also important!
 */
class KeyHole extends Interactor {

  ArrayList<UnlockListener> listeners = new ArrayList<UnlockListener>();
  void addListener(UnlockListener l) { if (!listeners.contains(l)) { listeners.add(l); }}
  void removeListener(UnlockListener l) { listeners.remove(l); }

  KeyHole(float x, float y) {
    super("Keyhole");
    setPosition(x,y);
    setupStates();
  }

  void setupStates() {
    State keyhole = new State("idle","graphics/assorted/Keyhole.gif");
    addState(keyhole);
    keyhole.sprite.align(CENTER,BOTTOM);
  }

  void overlapOccurredWith(Actor other, float[] overlap) {
    super.overlapOccurredWith(other, overlap);
    if (other instanceof Mario) {
      Mario m = (Mario) other;
      if (m.hasKey) {
        m.removeKey();
        for(UnlockListener l: listeners) {
          l.unlocked(m, this);
        }
      }
    }
  }
}

/**
 * keyhole listeners must implement this interface
 */
interface UnlockListener {
  void unlocked(Actor by, KeyHole hole);
}

/**
 * Tube trigger - teleports between locations
 */
class TeleportTrigger extends Trigger {
  float popup_speed = -40;
  float tx, ty;
  Boundary lid;
  TeleportTrigger(float tx, float ty) {
    super("teleporter");
    this.tx = tx;
    this.ty = ty;
  }
  void setLid(Boundary lid) { 
    this.lid = lid;
  }
  void run(LevelLayer layer, Actor actor, float[] intersection) {
    // spit mario back out
    actor.stop();
    actor.setPosition(tx, ty);
    actor.setImpulse(0, popup_speed);
    if (lid != null) {
      lid.enable();
    }
  }
}

/**
 * Tube trigger - teleports between layers
 */
class LayerTeleportTrigger extends TeleportTrigger {
  String layerName;
  LayerTeleportTrigger(String _layer, float tx, float ty) {
    super(tx,ty);
    layerName = _layer;
  }
  void run(LevelLayer layer, Actor actor, float[] intersection) {
    super.run(layer, actor, intersection);
    if(actor instanceof Player) {
      Player p = (Player) actor;      
      LevelLayer current = p.layer;
      current.removePlayer(p);
      LevelLayer next = current.parent.getLevelLayer(layerName);
      next.addPlayer(p);
    }
  }
}

/**
 * Tube trigger - teleports between levels
 */
class LevelTeleportTrigger extends TeleportTrigger {
  String levelName;
  LevelTeleportTrigger(String _level, float x, float y, float w, float h, float tx, float ty) {
    super(tx,ty);
    levelName = _level;
  }
  void run(LevelLayer layer, Actor actor, float[] intersection) {
    super.run(layer, actor, intersection);
    if(actor instanceof Player) {
      Player p = (Player) actor;
      setActiveScreen(levelName);
      MarioLevel a = (MarioLevel) activeScreen;
      a.updateMario(p);
    }
  }
}

/**
 * Removable boundary for pipes, acts as lid
 */
class PipeBoundary extends Boundary {
  // wrapper constructor
  PipeBoundary(float x1, float y1, float x2, float y2) {
    super(x1, y1, x2, y2);
    SoundManager.load(this, "audio/Pipe.mp3");
  }
  // used to effect "teleporting" in combination with the teleport trigger
  void trigger(Player p) {
    p.setPosition((x+xw)/2, y);
    disable();
    SoundManager.play(this);
  }
}

/***************************************
 *                                     *
 *             TRIGGERS                *
 *                                     *
 ***************************************/

abstract class MarioTrigger extends Trigger {
  float px, py, ix, iy;
  MarioTrigger(String name, float x, float y, float w, float h, float _px, float _py, float _ix, float _iy) {
    super(name, x, y, w, h);
    px = _px;
    py = _py;
    ix = _ix;
    iy = _iy;
  }
}


/**
 * triggers a koopa trooper 350px to the right
 */
class KoopaTrigger extends MarioTrigger {
  KoopaTrigger(float x, float y, float w, float h, float _px, float _py, float _ix, float _iy) {
    super("koopa", x, y, w, h, _px, _py, _ix, _iy);
  }
  void run(LevelLayer layer, Actor actor, float[] intersection) {
    Koopa k = new Koopa(x+px, py);
    if (fx>0) { 
      k.setHorizontalFlip(true);
    }
    layer.addInteractor(k);
    // remove this trigger so that it's not repeated
    removeTrigger();
  }
}


/**
 * triggers a Banzai Bill!
 */
class BanzaiBillTrigger extends MarioTrigger {
  BanzaiBillTrigger(float x, float y, float w, float h, float _px, float _py, float _ix, float _iy) {
    super("banzai bill", x, y, w, h, _px, _py, _ix, _iy);
  }
  void run(LevelLayer layer, Actor actor, float[] intersection) {
    BanzaiBill b = new BanzaiBill(x+px, py);
    if (fx>0) { b.setHorizontalFlip(true); }
    b.setImpulse(ix, iy);
    layer.addInteractor(b);
    removeTrigger();
  }
}

/**
 * triggers a hidden mushroom
 */
class MushroomTrigger extends MarioTrigger {
  MushroomTrigger(float x, float y, float w, float h, float _px, float _py, float _ix, float _iy) {
    super("mushroom", x, y, w, h, _px, _py, _ix, _iy);
  }
  void run(LevelLayer layer, Actor actor, float[] intersection) {
    Mushroom m = new Mushroom(px, py);
    m.setImpulse(ix, iy);
    m.setForces(0,DOWN_FORCE);
    m.setAcceleration(0,0);
    layer.addForPlayerOnly(m);
    removeTrigger();
  }
}

