/**
 * This is a helper class for Positionables,
 * used for recording "previous" frame data
 * in case we need to roll back, or do something
 * that requires multi-frame information
 */
class Position {
  /**
   * A monitoring object for informing JavaScript
   * about the current state of this Positionable.
   */
  boolean monitoredByJavaScript = false;
  void setMonitoredByJavaScript(boolean monitored) { monitoredByJavaScript = monitored; }
  
// ==============
//   variables
// ==============

  // dimensions and positioning
  float x=0, y=0, width=0, height=0;

  // mirroring
  boolean hflip = false;   // draw horizontall flipped?
  boolean vflip = false;   // draw vertically flipped?

  // transforms
  float ox=0, oy=0;        // offset in world coordinates
  float sx=1, sy=1;        // scale factor
  float r=0;               // rotation (in radians)

  // impulse "vector"
  float ix=0, iy=0;

  // impulse factor per frame (acts as accelator/dampener)
  float ixF=1, iyF=1;

  // external force "vector"
  float fx=0, fy=0;

  // external acceleration "vector"
  float ixA=0, iyA=0;
  int aFrameCount=0;

  // which direction is this positionable facing,
  // based on its movement in the last frame?
  // -1 means "not set", 0-2*PI indicates the direction
  // in radians (0 is ->, values run clockwise) 
  float direction = -1;

  // administrative
  boolean animated = true;  // does this object move?
  boolean visible = true;   // do we draw this object?

// ========================
//  quasi-copy-constructor
// ========================

  void copyFrom(Position other) {
    x = other.x;
    y = other.y;
    width = other.width;
    height = other.height;
    hflip  = other.hflip;
    vflip  = other.vflip;
    ox = other.ox;
    oy = other.oy;
    sx = other.sx;
    sy = other.sy;
    r = other.r;
    ix = other.ix;
    iy = other.iy;
    ixF = other.ixF;
    iyF = other.iyF;
    fx = other.fx;
    fy = other.fy;
    ixA = other.ixA;
    iyA = other.iyA;
    aFrameCount = other.aFrameCount;
    direction  = other.direction;
    animated  = other.animated;
    visible  = other.visible;
  }

// ==============
//    methods
// ==============

  /**
   * Get this positionable's bounding box
   */
  float[] getBoundingBox() {
    return new float[]{x+ox-width/2, y-oy-height/2,  // top-left
                       x+ox+width/2, y-oy-height/2,  // top-right
                       x+ox+width/2, y-oy+height/2,  // bottom-right
                       x+ox-width/2, y-oy+height/2}; // bottom-left
  }

  /**
   * Primitive sprite overlap test: bounding box
   * overlap using midpoint distance.
   */
  float[] overlap(Position other) {
    float w=width, h=height, ow=other.width, oh=other.height;
    float[] bounds = getBoundingBox();
    float[] obounds = other.getBoundingBox();
    if(bounds==null || obounds==null) return null;
    
    float xmid1 = (bounds[0] + bounds[2])/2;
    float ymid1 = (bounds[1] + bounds[5])/2;
    float xmid2 = (obounds[0] + obounds[2])/2;
    float ymid2 = (obounds[1] + obounds[5])/2;

    float dx = xmid2 - xmid1;
    float dy = ymid2 - ymid1;
    float dw = (w + ow)/2;
    float dh = (h + oh)/2;

    // no overlap if the midpoint distance is greater
    // than the dimension half-distances put together.
    if(abs(dx) > dw || abs(dy) > dh) {
      return null;
    }

    // overlap
    float angle = atan2(dy,dx);
    if(angle<0) { angle += 2*PI; }
    float safedx = dw-dx,
          safedy = dh-dy;
    return new float[]{dx, dy, angle, safedx, safedy};
  }

  /**
   * Apply all the transforms to the
   * world coordinate system prior to
   * drawing the associated Positionable
   * object.
   */
  void applyTransforms() {
    // we need to make sure we end our transforms
    // in such a way that integer coordinates lie
    // on top of canvas grid coordinates. Hence
    // all the (int) casting in translations.
    translate((int)x, (int)y);
    if (r != 0) { rotate(r); }
    if(hflip) { scale(-1,1); }
    if(vflip) { scale(1,-1); }
    scale(sx,sy);
    translate((int)ox, (int)oy);
  }

  /**
   * Good old toString()
   */
  String toString() {
    return "position: "+x+"/"+y+
           ", impulse: "+ix+"/"+iy+
           " (impulse factor: "+ixF+"/"+iyF+")" +
           ", forces: "+fx+"/"+fy+
           " (force factor: "+ixA+"/"+iyA+")"+
           ", offset: "+ox+"/"+oy;
  }
}
