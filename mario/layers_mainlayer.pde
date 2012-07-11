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
