class DarkLevelLayer extends MarioLayer {
  DarkLevelLayer(Level parent) {
    super(parent);

    // repeating background sprite image
    Sprite bgsprite = new Sprite("graphics/backgrounds/bonus.gif");
    bgsprite.align(RIGHT, TOP);
    TilingSprite backdrop = new TilingSprite(bgsprite, 0, 0, width, height);
    addStaticSpriteBG(backdrop);      

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

    // set up two tubes
    addTube(0, height-16, null);
    addTube(width-32, height-16, new LevelTeleportTrigger("Main Level",  width-30,height-34,30,2,  804+16,373));
    
    addKeyHole(width/2, height-28);
  }
}
