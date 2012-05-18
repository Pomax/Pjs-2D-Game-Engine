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
