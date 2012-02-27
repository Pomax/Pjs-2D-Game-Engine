/**
 * A generic, abstract shape class.
 * This class has room to fit anything
 * up to to cubic Bezier curves, with
 * additional parameters for x/y scaling
 * at start and end points, as well as
 * rotation at start and end points.
 */
abstract class ShapePrimitive {
  String type = "unknown";

  // coordinate values
  float x1=0, y1=0, cx1=0, cy1=0, cx2=0, cy2=0, x2=0, y2=0;

  // transforms at the end points
  float sx1=1, sy1=1, sx2=1, sy2=1, r1=0, r2=0;

  // must be implemented by extensions
  abstract void draw();

  // set the scale values for start and end points
  void setScales(float _sx1, float _sy1, float _sx2, float _sy2) {
    sx1=_sx1; sy1=_sy1; sx2=_sx2; sy2=_sy2;
  }

  // set the rotation at start and end points
  void setRotations(float _r1, float _r2) {
    r1=_r1; r2=_r2;
  }

  // generate a string representation of this shape.
  String toString() {
    return type+" "+x1+","+y1+","+cx1+","+cy1+","+cx2+","+cy2+","+x2+","+y2+
           " - "+sx1+","+sy1+","+sx2+","+sy2+","+r1+","+r2;
  }
}

/**
 * This class models a dual-purpose 2D
 * point, acting either as linear point
 * or as tangental curve point.
 */
class Point extends ShapePrimitive {
  // will this behave as curve point?
  boolean cpoint = false;

  // since points have no "start and end", alias the values
  float x, y, cx, cy;

  Point(float x, float y) {
    type = "Point";
    this.x=x; this.y=y;
    this.x1=x; this.y1=y;
  }

  // If we know the next point, we can determine
  // the rotation for the sprite at this point.
  void setNext(float nx, float ny) {
    if (!cpoint) {
      r1 = atan2(ny-y,nx-x);
    }
  }

  // Set the curve control values, and turn this
  // into a curve point (even if it already was)
  void setControls(float cx, float cy) {
    cpoint = true;
    this.cx=(cx-x); this.cy=(cy-y);
    this.cx1=this.cx; this.cy1=this.cy;
    r1 = PI + atan2(y-cy,x-cx);
  }

  // Set the rotation for the sprite at this point
  void setRotation(float _r) {
    r1=_r;
  }

  void draw() {
    // if curve, show to-previous control point
    if (cpoint) {
      line(x-cx,y-cy,x,y);
      ellipse(x-cx,y-cy,3,3);
    }
    point(x,y);
    // if curve, show to-next control point 2
    if (cpoint) {
      line(x,y,x+cx,y+cy);
      ellipse(x+cx,y+cy,3,3);
    }
  }

  // this method gets called during edit mode for setting scale and/or rotation
  boolean over(float mx, float my, int boundary) {
    boolean mainpoint = (abs(x-mx) < boundary && abs(y-my) < boundary);
    return mainpoint || overControl(mx, my, boundary);
  }

  // this method gets called during edit mode for setting rotation
  boolean overControl(float mx, float my, int boundary) {
    return (abs(x+cx-mx) < boundary && abs(y+cy-my) < boundary);
  }
}

/**
 * Generic line class
 */
class Line extends ShapePrimitive {
  // Vanilla constructor
  Line(float x1, float y1, float x2, float y2) {
    type = "Line";
    this.x1=x1; this.y1=y1; this.x2=x2; this.y2=y2;
  }
  // Vanilla draw method
  void draw() {
    line(x1,y1,x2,y2);
  }
}

/**
 * Generic cubic Bezier curve class
 */
class Curve extends ShapePrimitive {
  // Vanilla constructor
  Curve(float x1, float y1, float cx1, float cy1, float cx2, float cy2, float x2, float y2) {
    type = "Curve";
    this.x1=x1; this.y1=y1; this.cx1=cx1; this.cy1=cy1; this.cx2=cx2; this.cy2=cy2; this.x2=x2; this.y2=y2;
  }
  // Vanilla draw method
  void draw() {
    bezier(x1,y1,cx1,cy1,cx2,cy2,x2,y2);
  }
}
