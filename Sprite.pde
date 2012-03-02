/**
 * Sprites are fixed dimension animated 2D graphics,
 * with separate images for each frame of animation.
 *
 * Sprites can be positioned, transformed (translated,
 * scaled, rotated and flipped), and moved along a
 * path either manually or automatically.
 */
class Sprite extends Positionable {

  State state;
  SpritePath path = new SpritePath();
  float halign=0, valign=0;

  // frame data
  PImage[] frames;         // sprite frames
  int numFrames=0;         // frames.length cache
  float frameFactor=1;     // determines that frame serving compression/dilation

  boolean hflip = false;   // draw horizontall flipped?
  boolean vflip = false;   // draw vertically flipped?


  // animation properties
  boolean visible = true;  // should the sprite be rendered when draw() is called?
  boolean animated = true; // is this sprite "alive"?
  int frameOffset = 0;      // this determines which frame the sprite synchronises on
  int framesServed = 0;

  /**
   * Shortcut constructor, if the sprite has one frame
   */
  Sprite(String spritefile) {
    this(spritefile, 1, 1, 0, 0);
  }

  /**
   * Shortcut constructor, to build a Sprite directly off of a sprite map image.
   */
  Sprite(String spritefile, int rows, int columns) {
    this(spritefile, rows, columns, 0, 0);
  }

  /**
   * Shortcut constructor, to build a Sprite directly off of a sprite map image.
   */
  Sprite(String spritefile, int rows, int columns, float xpos, float ypos) {
    this(SpriteMapHandler.cutTiledSpritesheet(spritefile, columns, rows, true), xpos, ypos, true);
  }

  /**
   * Full constructor.
   */
  private Sprite(PImage[] _frames, float _xpos, float _ypos, boolean _visible) {
    setFrames(_frames);
    visible = _visible;
  }

  void setState(State _state) {
    state = _state;
  }

  /**
   * Bind sprite frames and record the sprite dimensions
   */
  void setFrames(PImage[] _frames) {
    frames = _frames;
    width = _frames[0].width;
    height = _frames[0].height;
    numFrames = _frames.length;
  }

  /**
   * Get the alpha channel for a pixel
   */
  float getAlpha(float _x, float _y) {
    int x = (int) _x;
    int y = (int) _y;
    PImage frame = frames[currentFrame];
    return alpha(frame.get(x,y));
  }

  /**
   * Get the number of frames for this sprite
   */
  int getFrameCount() {
    return numFrames;
  }

  /**
   * Check whether this sprite is animated
   * (i.e. still has frames left to draw).
   */
  boolean isAnimated() {
    return animated;
  }

  /**
   * Align this sprite, by treating its
   * indicated x/y align values as
   * center point.
   */
  void align(int _halign, int _valign) {
    if(_halign==LEFT) { halign=width/2; }
    else if(_halign==CENTER) { halign=0; }
    else if(_halign==RIGHT)  { halign=-width/2; }
    ox = halign;

    if(_valign==TOP) { valign=-height/2; }
    else if(_valign==CENTER) { valign=0; }
    else if(_valign==BOTTOM)  { valign=height/2; }
    oy = valign;
  }

  /**
   * if set, sprites are not rotation-interpolated
   * on paths, even if they're curved.
   */
  void setNoRotation(boolean _noRotation) {
    path.setNoRotation(_noRotation);
  }

  /**
   * Flip all frames for this sprite horizontally.
   */
  void flipHorizontal() {
    hflip = !hflip;
    ox = -ox;
  }

  /**
   * Flip all frames for this sprite vertically.
   */
  void flipVertical() {
    vflip = !vflip;
    oy = -oy;
  }

// -- draw methods

  /**
   * Set the frame offset to sync the sprite animation
   * based on a different frame in the frame set.
   */
  void setFrameOffset(int offset) {
    frameOffset = offset;
  }

  /**
   * Set the frame factor for compressing or dilating
   * frame serving. Default is '1'. 0.5 will make the
   * frame serving twice as fast, 2 will make it twice
   * as slow.
   */
  void setAnimationSpeed(float factor) {
    frameFactor = factor;
  }

  /**
   * Set the frame offset to sync the sprite animation
   * based on a different frame in the frame set.
   */
  void setPathOffset(int offset) {
    path.setOffset(offset);
  }

  // private current frame counter
  private int currentFrame;

  /**
   * Get the 'current' sprite frame.
   */
  PImage getFrame() {
    // update sprite based on path frames
    currentFrame = getCurrentFrameNumber();
    if (path.size()>0) {
      float[] pathdata = path.getNextFrameInformation();
      setScale(pathdata[2], pathdata[3]);
      setRotation(pathdata[4]);
      state.setActorOffsets(pathdata[0], pathdata[1]);
      state.setActorDimensions(width*sx, height*sy, halign*sx, valign*sy);
    }
    return frames[currentFrame];
  }

  /**
   * Get the 'current' frame number. If this
   * sprite is no longer alive (i.e. it reached
   * the end of its path), it will return the
   * number for the last frame in the set.
   */
  int getCurrentFrameNumber() {
    if(!path.looping && framesServed == path.size()) {
      state.finished();
      animated = false;
      return numFrames-1;
    }
    float frame = ((frameCount+frameOffset)*frameFactor) % numFrames;
    framesServed++;
    return (int)frame;
  }

  /**
   * Set up the coordinate transformations
   * and draw the sprite's "current" frame
   * at the correct location.
   */
  void draw() {
    if (visible) {
      PImage img = getFrame();
      pushMatrix();
      {
        translate(x, y);
        if (r != 0) { rotate(r); }
        if(hflip) { scale(-1,1); }
        if(vflip) { scale(1,-1); }
        scale(sx,sy);
        translate(-width/2 - ox, -height/2 - oy);
        image(img, 0, 0);
      }
      popMatrix();
    }
  }

  // pass-through/unused
  void draw(float _a, float _b, float _c, float _d) { draw(); }
  void drawObject() {}
  boolean drawableFor(float _a, float _b, float _c, float _d) { return true; }
  
// -- pathing informmation

  void reset() {
    if(path.size()>0) {
      path.reset();
      animated = true; }
    framesServed = 0;
    frameOffset = -frameCount;
  }

  void stop() {
    animated=false;
  }

  /**
   * this sprite may be swapped out if it
   * finished running through its path animation.
   */
  boolean mayChange() {
    if(path.size()==0) {
      return true;
    }
    return !animated; }

  /**
   * Set the path loop property.
   */
  void setLooping(boolean v) {
    path.setLooping(v);
  }

  /**
   * Clear path information
   */
  void clearPath() {
    path = new SpritePath();
  }

  /**
   * Add a path point
   */
  void addPathPoint(float x, float y, float sx, float sy, float r, int duration)
  {
    path.addPoint(x, y, sx, sy, r, duration);
  }

  /**
   * Set up a (linear interpolated) path from point [1] to point [2]
   */
  void addPathLine(float x1, float y1, float sx1, float sy1, float r1,
                   float x2, float y2, float sx2, float sy2, float r2,
                   float duration)
  // pointless comment to make the 11 arg functor look slightly less horrible
  {
    path.addLine(x1,y1,sx1,sy1,r1,  x2,y2,sx2,sy2,r2,  duration);
  }

  /**
   * Set up a (linear interpolated) path from point [1] to point [2]
   */
  void addPathCurve(float x1, float y1, float sx1, float sy1, float r1,
                   float cx1, float cy1,
                   float cx2, float cy2,
                    float x2, float y2, float sx2, float sy2, float r2,
                    float duration,
                    float slowdown_ratio)
  // pointless comment to make the 16 arg functor look slightly less horrible
  {
    path.addCurve(x1,y1,sx1,sy1,r1,  cx1,cy1,cx2,cy2,  x2,y2,sx2,sy2,r2,  duration, slowdown_ratio);
  }
}
