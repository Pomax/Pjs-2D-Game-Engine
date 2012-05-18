
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

  // debug intercept for keypressed
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
        for(Interactor i: bounded_interactors) { i.debug = !i.debug; }
        for(Player p: players) { p.debug = !p.debug; }
      }
    }
    super.keyPressed(key, keyCode);
  }
}
