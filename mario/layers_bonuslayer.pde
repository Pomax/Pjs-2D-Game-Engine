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
