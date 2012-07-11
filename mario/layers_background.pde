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
