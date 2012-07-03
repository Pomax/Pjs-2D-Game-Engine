/**
 * This class defines a path along which
 * a sprite is transformed.
 */
class SpritePath {

  // container for all path points
  ArrayList<FrameInformation> data;

  // animation path offset
  int pathOffset = 0;

  // how many path frames have been served yet?
  int servedFrame = 0;

  // is this path cyclical?
  boolean looping = false;
  boolean noRotation = false;

  // private class for frame information
  private class FrameInformation {
    float x, y, sx, sy, r;
    FrameInformation(float _x, float _y, float _sx, float _sy, float _r) {
      x=_x; y=_y; sx=_sx; sy=_sy; r=_r; }
    String toString() {
      return "FrameInformation ["+x+", "+y+", "+sx+", "+sy+", "+r+"]"; }}

  /**
   * constructor
   */
  SpritePath() {
    data = new ArrayList<FrameInformation>();
  }

  /**
   * How many frames are there in this path?
   */
  int size() {
    return data.size();
  }

  /**
   * Check whether this path loops
   */
  boolean isLooping() {
    return looping;
  }

  /**
   * Set this path to looping or terminating
   */
  void setLooping(boolean v) {
    looping = v;
  }

  /**
   * if set, sprites are not rotation-interpolated
   * on paths, even if they're curved.
   */
  void setNoRotation(boolean _noRotation) {
    noRotation = _noRotation;
  }

  /**
   * Add frames based on a single point
   */
  void addPoint(float x, float y, float sx, float sy, float r, int span) {
    FrameInformation pp = new FrameInformation(x,y,sx,sy,r);
    while(span-->0) { data.add(pp); }
  }

  /**
   * Add a linear path section, using {FrameInformation} at frame X
   * to using {FrameInformation} at frame Y. Tweening is based on
   * linear interpolation.
   */
  void addLine(float x1, float y1, float sx1, float sy1, float r1,
               float x2, float y2, float sx2, float sy2, float r2,
               float duration)
  // pointless comment to make the 11 arg functor look slightly less horrible
  {
    float t, mt;
    for (float i=0; i<=duration; i++) {
      t = i/duration;
      mt = 1-t;
      addPoint(mt*x1 + t*x2,
               mt*y1 + t*y2,
               mt*sx1 + t*sx2,
               mt*sy1 + t*sy2,
               (noRotation ? r1 : mt*r1 + t*r2),
               1);
    }
  }

  /**
   * Add a cubic bezir curve section, using {FrameInformation}1 at
   * frame X to using {FrameInformation}2 at frame Y. Tweening is based
   * on an interpolation of linear interpolation and cubic bezier
   * interpolation, using a mix ration indicated by <slowdown_ratio>.
   */
  void addCurve(float x1, float y1, float sx1, float sy1, float r1,
               float cx1, float cy1,
               float cx2, float cy2,
                float x2, float y2, float sx2, float sy2, float r2,
                float duration,
                float slowdown_ratio)
  // pointless comment to make the 16 arg functor look slightly less horrible
  {
    float pt, t, mt, x, y, dx, dy, rotation;
    // In order to perform double interpolation, we need both the
    // cubic bezier interpolation coefficients, which are just 't',
    // and the linear interpolation coefficients, which requires a
    // time reparameterisation of the curve. We get those as follows:
    float[] trp = SpritePathChunker.getTimeValues(x1, y1, cx1, cy1, cx2, cy2, x2, y2, duration);

    // loop through the frames and determine the frame
    // information at each associated time value.
    int i, e=trp.length;
    for (i=0; i<e; i++) {

      // plain [t]
      pt = (float)i/(float)e;

      // time repameterised [t]
      t = trp[i];

      // The actual [t] used depends on the mix ratio. A mix ratio of 1 means sprites slow down
      // along curves based on how strong the curve is, a ration of 0 means the sprite travels
      // at a fixed speed. Anything in between runs at a linear interpolation of the two.
      if (slowdown_ratio==0) {}
      else if (slowdown_ratio==1) { t = pt; }
      else { t = slowdown_ratio*pt + (1-slowdown_ratio)*t; }

      // for convenience, we alias (1-t)
      mt = 1-t;

      // Get the x/y coordinate for this time value:
      x = getCubicBezierValue(x1,cx1,cx2,x2,t,mt);
      y = getCubicBezierValue(y1,cy1,cy2,y2,t,mt);

      // Get the rotation at this coordinate:
      dx = getCubicBezierDerivativeValue(x1,cx1,cx2,x2,t);
      dy = getCubicBezierDerivativeValue(y1,cy1,cy2,y2,t);
      rotation = atan2(dy,dx);

      // NOTE:  if this was a curve based on linear->curve points, the first point will
      // have an incorrect dx/dy of (0,0), because the first control point is equal to the
      // starting coordinate. Instead, we must find dx/dy based on the next [t] value!
      if(i==0 && rotation==0) {
        float nt = trp[1], nmt = 1-nt;
        dx = getCubicBezierValue(x1,cx1,cx2,x2,nt,nmt) - x;
        dy = getCubicBezierValue(y1,cy1,cy2,y2,nt,nmt) - y;
        rotation = atan2(dy,dx); }

      // Now that we have all the frame information, interpolate and move on
      addPoint(x, y, mt*sx1 + t*sx2,  mt*sy1 + t*sy2, (noRotation? r1 : rotation), 1);
    }
  }

  // private cubic bezier value computer
  private float getCubicBezierValue(float v1, float c1, float c2, float v2, float t, float mt) {
    float t2 = t*t;
    float mt2 = mt*mt;
    return mt*mt2 * v1 + 3*t*mt2 * c1 + 3*t2*mt * c2 + t2*t * v2;
  }

  // private cubic bezier derivative value computer
  private float getCubicBezierDerivativeValue(float v1, float c1, float c2, float v2, float t) {
    float tt = t*t, t6 = 6*t, tt9 = 9*tt;
    return c2*(t6 - tt9) + c1*(3 - 12*t + tt9) + (-3 + t6)*v1 + tt*(-3*v1 + 3*v2);
  }

  /**
   * Set the animation path offset
   */
  void setOffset(int offset) {
    pathOffset = offset;
  }

  /**
   * effect a path reset
   */
  void reset() {
    pathOffset = 0;
    servedFrame = 0;
  }

  /**
   * get the next frame's pathing information
   */
  float[] getNextFrameInformation() {
    int frame = pathOffset + servedFrame++;
    if(frame<0) { frame = 0; }
    else if(!looping && frame>=data.size()) { frame = data.size()-1; }
    else { frame = frame % data.size(); }
    FrameInformation pp = data.get(frame);
    return new float[]{pp.x, pp.y, pp.sx, pp.sy, pp.r};
  }

  /**
   * String representation for this path
   */
  String toString() {
    String s = "";
    for(FrameInformation p: data) { s += p.toString() + "\n"; }
    return s;
  }

  /**
   * This function is really more for debugging than anything else.
   * It will render the entire animation path without any form of
   * caching, so it can drive down framerates by quite a bit.
   */
  void draw() {
    if(data.size()==0) return;
    ellipseMode(CENTER);
    FrameInformation cur, prev = data.get(0);
    for(int i=0; i<data.size(); i++) {
      cur = data.get(i);
      line(prev.x,prev.y, cur.x, cur.y);
      ellipse(cur.x,cur.y,5,5);
      prev = cur;
    }
  }
}
