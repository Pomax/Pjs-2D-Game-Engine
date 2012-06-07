/**
 * Collision detection is a complicated thing.
 * In order not to pollute the Boundary class,
 * it's handled by this static computing class.
 */
static class CollisionDetection {

  /**
   * Static classes need global sketch binding
   */
  private static PApplet sketch;
  public static void init(PApplet s) { sketch = s; } 

  /**
   * Perform actor/boundary collision detection
   */
  static void interact(Boundary b, Actor a)
  {
    if (a.isAttachedTo(b)) { return; }

    float[] correction = blocks(b,a);
    if(correction != null) {
      /*
      sketch.stroke(0);
      sketch.line(a.getX()-10, a.getY()-10, a.getX()+10, a.getY()+10);
      sketch.line(a.getX()-10, a.getY()+10, a.getX()+10, a.getY()-10);

      sketch.stroke(255,0,0);
      sketch.line(a.getX(), a.getY(), a.getX()+correction[0], a.getY()+correction[1]);
      */
      a.attachTo(b, correction); }
  }

  /**
   * Is this boundary blocking the specified actor?
   */
  static float[] blocks(Boundary b, Actor a)
  {
    // we don't block in the pass-through direction.
    if(b.allowPassThrough(a.ix, a.iy)) { return null; }

    float[] current = a.getBoundingBox(),
            previous = a.previous.getBoundingBox(),
            line = {b.x, b.y, b.xw, b.yh};

    return CollisionDetection.getLineRectIntersection(line, current, previous);
  }

// =================================================================

  private static float[] current_dots = {0,0,0,0,0,0,0,0};
  private static float[] previous_dots = {0,0,0,0,0,0,0,0};
  private static ArrayList<float[]> intersections = new ArrayList<float[]>();
  private static float[] checkLines = {0,0,0,0,0,0,0,0};
  private static float[] ZERO_DIFFERENCE = {0,0};

  // constant for indicating a coordinate is an intersection
  final static int INTERSECTION = 0;

  // constant for indicating a coordinate is a full contained coordinate
  final static int CONTAINED = 1;


  /**
   * Line-through-box intersection algorithm.
   *
   * There are a few possibilities, with B() meaning
   * "on blocking side", I() meaning "intersecting"
   * and P() meaning "on pass-through side":
   *
   *               |
   * (1)  []  []  <|    =  B(prev), B(current)
   *               |
   *
   *              |
   * (2)  []    [<|]   =  B(prev), B(current) and I(current) and P(current)
   *              |
   *
   *           |
   * (3)  []  <|  []   =  B(prev), P(current)
   *           |
   *
   *        |
   * (4)  [<|]    []   =  B(prev) and I(prev) and P(prev), P(current)
   *        |
   *
   *
   *       |
   * (5)  <|  []  []   =  P(prev), P(current)
   *       |
   *
   * By computing the dot product for the eight corners of the two bounding
   * boxes, we can determine which of these situations we are in. Only in
   * (2) and (3) should we signal an intersection occuring. While (4) might
   * look like another case in which this should happen, we assume that
   * because the "previous" state is boundary overlapping, it was permitted
   * earlier (for instance, it moved through the boundary in the allowed
   * direction, but then moved back before having fully passed the boundary).
   */
  static float[] getLineRectIntersection(float[] line, float[] current, float[] previous)
  {
    int B_current = 0, B_previous = 0, B_sum = 0;
    float ox=line[0], oy=line[1], tx=line[2], ty=line[3],
          dotx = tx-ox, doty = ty-oy,
          otlen = sqrt(dotx*dotx + doty*doty),
          x, y, dx, dy, len, dotproduct;

    // normalised boundary vector
    dotx /= otlen;
    doty /= otlen;

    // note: we want the dot product with the
    // vector that is perpendicular to the boundary!
    float p = PI/2, cosp = cos(p), sinp = sin(p),
          pdx = dotx*cosp - doty*sinp,
          pdy = dotx*sinp + doty*cosp;

    // how many corners are blocked in [current]?
    for(int i=0; i<8; i+=2) {
      x = current[i];
      y = current[i+1];
      dx = x-ox;
      dy = y-oy;
      len = sqrt(dx*dx+dy*dy);
      dx /= len;
      dy /= len;
      dotproduct = dx*pdx + dy*pdy;
      if (dotproduct < 0) { B_current++; }
      current_dots[i] = dotproduct;
    }

    // how many corners are blocked in [previous]? (copied for speed)
    for(int i=0; i<8; i+=2) {
      x = previous[i];
      y = previous[i+1];
      dx = x-ox;
      dy = y-oy;
      len = sqrt(dx*dx+dy*dy);
      dx /= len;
      dy /= len;
      dotproduct = dx*pdx + dy*pdy;
      if (dotproduct < 0) { B_previous++; }
      previous_dots[i] = dotproduct;
    }

    // cases (1) or (5)?
    B_sum = B_current + B_previous;
    if (B_sum == 0 || B_sum == 8) {
//      println("case " + (B_sum==8? "1" : "5"));
      return null;
    }

    // case (4)?
    if (B_previous < 4 && B_current == 0) {
//      println("case 4");
      return null;
    }

    // Before we continue, find the point in [previous]
    // that is closest to the boundary, since that'll
    // cross the boundary first (based on its dot product
    // value.)
    int corner=-1, curcorner;
    float dotvalue = 999999, curval;
    for(curcorner=0; curcorner<8; curcorner+=2) {
      curval = abs(previous_dots[curcorner]);
      if(curval<dotvalue) {
        corner = curcorner;
        dotvalue = curval; }}

    // Right then. Case (2) or (3)?
    if (B_previous == 4) {
      int currentCase = 2;
      // for (2) and (3) the approach is essentially
      // the same, except that we need different bounding
      // boxes to determine the intersection. For (2) we
      // can use the [current] bounding box, but for (3)
      // we need to construct a new box that is spanned by
      // the two points next to the "hot" corner in both
      // [previous] and [current].
      checkLines = new float[8];
      arrayCopy(current,0,checkLines,0,8);

      // if we're seeing case (3), set up bbox correctly.
      if (B_current < 4) {
//        println("case 3");
        currentCase = 3;
        // two of these edges are guaranteed to not have intersections,
        // since otherwise the intersection would be inside either
        // [previous] or [current], which is case (2) instead.
        checkLines = new float[]{previous[(corner)%8], previous[(corner+1)%8],
                                 previous[(corner+2)%8], previous[(corner+3)%8],
                                 current[(corner+2)%8],  current[(corner+3)%8],
                                 current[(corner)%8],  current[(corner+1)%8]};
      }
      else
      { 
//        println("case 2"); 
      }

      // Now that we have the correct box, perform line/line
      // intersection detection for each edge on the box.
      intersections.clear();
      float x1=checkLines[0], y1=checkLines[1], x2=x1, y2=y1;
      for (int i=0, last=checkLines.length; i<last; i+=2) {
        x2 = checkLines[(i+2)%last];
        y2 = checkLines[(i+3)%last];
        float[] intersection = getLineLineIntersection(ox,oy,tx,ty, x1,y1,x2,y2, false);
        if (intersection!=null) {
          intersections.add(intersection);
          if(intersections.size()==2) { break; }}
        x1 = x2;
        y1 = y2;
      }

      // How many intersections did we find?
      // (We can have zero, one, or two)
      int intersectionCount = intersections.size();

      // if we have two intersections, it's
      // relatively easy to determine by how
      // much we should move back.
      if (intersectionCount == 2) {
        float px = previous[corner],
              py = previous[corner+1],
              cx = current[corner],
              cy = current[corner+1];

        float[] i1 = intersections.get(0),
                 i2 = intersections.get(1);

//        println("***");
        float[] ideal = getLineLineIntersection(px,py,cx,cy, i1[0],i1[1],i2[0],i2[1], false);
        if (ideal == null) { 
          println("error: could not find the case "+currentCase+" ideal point based on corner ["+corner+"]");
          /*
          println("tried to find the intersection between:");
          println("[1] "+px+","+py+","+cx+","+cy+" (blue)");
          println("[2] "+i1[0]+","+i1[1]+","+i2[0]+","+i2[1]+" (green)");
          //debugfunctions_drawBoundingBox(current,sketch);
          //debugfunctions_drawBoundingBox(previous,sketch);
          debugfunctions_drawBoundingBox(checkLines,sketch);
          
          sketch.noLoop();
          sketch.stroke(0,200,255);
          sketch.line(px,py,cx,cy);
          sketch.stroke(0,255,0);
          sketch.line(i1[0],i1[1],i2[0],i2[1]);
          */
          return new float[]{px-cx, py-cy}; 
        }
        return new float[]{ideal[0]-cx, ideal[1]-cy};
      }
      // if there's only one intersection,
      // additional math is required.
      else if (intersectionCount == 1) {
        // ...code goes here...
        return ZERO_DIFFERENCE;
      }
    }

    // Uncaught cases get a pass - with a warning.
//    println("unknown case! (B_current: "+B_current+", B_previous: "+B_previous+")");
    return null;
  }


  /**
   * Line-through-line intersection algorithm, using
   * relative rotation and intersection projection.
   *
   * returns float[] representing {x, y, onedge}, where
   *                 onedge=1 means on an edge, onedge=0
   *                 means somewhere inside the bounding box.
   */
  static float[] getLineLineIntersection(float x1, float y1, float x2, float y2, float x3, float y3, float x4, float y4, boolean colinearity)
  {
    float epsilon = 0.001;
    // convert lines to the generatised form [a * x + b + y = c]
    float a1 = -(y2 - y1), b1 = (x2 - x1), c1 = (x2 - x1) * y1 - (y2 - y1) * x1;
    float a2 = -(y4 - y3), b2 = (x4 - x3), c2 = (x4 - x3) * y3 - (y4 - y3) * x3;
    // find their intersection
    float d = a1 * b2 - a2 * b1;
    if (d == 0) {
      // Two lines are parallel: we are not interested in the
      // segment if the points are not colinear.
      if (!colinearity || (x2 - x3) * (y2 - y1) != (y2 - y3) * (x2 - x1)) {
        return null; 
      }
      // Solve the algebraic functions [x = (x1 - x0) * t + x0] for t
      float t1 = x3 != x4 ? (x1 - x3) / (x4 - x3) : (y1 - y3) / (y4 - y3);
      float t2 = x3 != x4 ? (x2 - x3) / (x4 - x3) : (y2 - y3) / (y4 - y3);
      if ((t1 < 0 && t2 < 0) || (t1 > 1 && t2 > 1)) {
        // points 1 and 2 are outside the points 3 and 4 segment
        return null;
      }
      // Clamp t values to the interval [0, 1]
      t1 = t1 < 0 ? 0 : t1 > 1 ? 1 : t1;
      t2 = t2 < 0 ? 0 : t2 > 1 ? 1 : t2;
      return new float[]{(x4 - x3) * t1 + x3, (y4 - y3) * t1 + y3,
              (x4 - x3) * t2 + x3, (y4 - y3) * t2 + y3};
    }
    // not colinear - find the intersection point
    else {
      float x = (c1 * b2 - c2 * b1) / d;
      float y = (a1 * c2 - a2 * c1) / d;
      // make sure the point can be found on both segments.
      if (x < min(x1, x2) - epsilon || max(x1, x2) + epsilon < x ||
          y < min(y1, y2) - epsilon || max(y1, y2) + epsilon < y ||
          x < min(x3, x4) - epsilon || max(x3, x4) + epsilon < x ||
          y < min(y3, y4) - epsilon || max(y3, y4) + epsilon < y) {
        // not on either, or both, segments.
        return null;
      }
      return new float[]{x, y};
    }
  }


  /**
   * Perform a coordinate tranlation/rotation so that
   * line (x3/y3, x4/y4) becomes (0/0, .../0), with
   * the other coordinates transformed accordingly
   *
   * returns float[9], with [0]/[1], [2]/[3], [4]/[5] and [6]/[7]
   *                   being four coordinate pairs, and [8] being
   *                   the angle of rotation used by this transform.
   */
  static float[] translateRotate(float x1, float y1, float x2, float y2, float x3, float y3, float x4, float y4, float angle, float cosine, float sine)
  {
    // First, translate all coordinates so that x3/y3 lies on 0/0
    x1 -= x3;   y1 -= y3;
    x2 -= x3;   y2 -= y3;
    x4 -= x3;   y4 -= y3;

    // Rotate (x1'/y1') about (0,0)
    float x1n = x1 * cosine - y1 * sine,
           y1n = x1 * sine + y1 * cosine;

    // Rotate (x2'/y2') about (0,0)
    float x2n = x2 * cosine - y2 * sine,
           y2n = x2 * sine + y2 * cosine;

    // Rotate (x4'/y4') about (0,0)
    float x4n = x4 * cosine - y4 * sine;

    // And then return the transformed coordinates, plus angle used
    return new float[] {x1n, y1n, x2n, y2n, 0, 0, x4n, 0, angle};
  }
}
