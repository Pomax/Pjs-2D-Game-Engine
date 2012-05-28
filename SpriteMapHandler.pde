/**
 * The sprite map handler is responsible for turning sprite maps
 * into frame arrays. Sprite maps are single images with multiple
 * animation frames spaced equally along the x and y axes.
 */
static class SpriteMapHandler {

  // We need a reference to the sketch, because
  // we'll be relying on it for image loading.
  static PApplet globalSketch;

  /**
   * This method must be called before cutTiledSpriteSheet can be used.
   * Typically this involves calling setSketch(this) in setup().
   */
  static void init(PApplet s) {
    globalSketch = s;
  }

  /**
   * wrapper for cutTileSpriteSheet cutting ltr/tb
   */
  static PImage[] cutTiledSpritesheet(String _spritesheet,int widthCount,int heightCount) {
    return cutTiledSpritesheet(_spritesheet, widthCount, heightCount, true);
  }

  /**
   * cut a sheet either ltr/tb or tb/ltr depending on whether leftToRightFirst is true or false, respectively.
   */
  private static PImage[] cutTiledSpritesheet(String _spritesheet, int widthCount, int heightCount, boolean leftToRightFirst) {
    // safety first.
    if (globalSketch == null) {
      println("ERROR: SpriteMapHandler requires a reference to the sketch. Call SpriteMapHandler.setSketch(this) in setup().");
    }

    // load the sprite sheet image
    PImage spritesheet = globalSketch.loadImage(_spritesheet);

    // loop through spritesheet and cut out images
    // this method assumes sprites are all the same size and tiled in the spritesheet
    int spriteCount = widthCount*heightCount;
    int spriteIndex = 0;
    int tileWidth = spritesheet.width/widthCount;
    int tileHeight = spritesheet.height/heightCount;

    // safety first: Processing.js and possibly other
    // implementations may require image preloading.
    if(tileWidth == 0 || tileHeight == 0) {
      println("ERROR: tile width or height is 0 (possible missing image preload for "+_spritesheet+"?)");
    }

    // we have all the information we need. Start cutting
    PImage[] sprites = new PImage[spriteCount];
    int i, j;

    // left to right, moving through the rows top to bottom
    if (leftToRightFirst){
      for (i = 0; i < heightCount; i++){
        for (j =0; j < widthCount; j++){
          sprites[spriteIndex++] = spritesheet.get(j*tileWidth,i*tileHeight,tileWidth,tileHeight);
        }
      }
    }

    // top to bottom, moving through the columns left to right
    else {
      for (i = 0; i < widthCount; i++){
        for (j =0; j < heightCount; j++){
          sprites[spriteIndex++] = spritesheet.get(i*tileWidth,j*tileHeight,tileWidth,tileHeight);
        }
      }
    }

    return sprites;
  }
}
