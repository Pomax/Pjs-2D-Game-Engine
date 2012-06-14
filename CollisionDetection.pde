/**
 * Collision detection is a complicated thing.
 * In order not to pollute the Boundary class,
 * it's handled by this static computing class.
 */
static class CollisionDetection {
  private static boolean debug = false;

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

    float[] bbox = a.getBoundingBox(),
             correction = blocks(b,a,bbox);

    if(correction != null) {
      //adjustForSpriteMask(b, a, bbox, correction);
      a.attachTo(b, correction); 
    }
  }


  /**
   * Is this boundary blocking the specified actor?
   *
   * @return null if no intersect, otherwise float[3]
   *         indices: [0] = dx, [1] = dy, [2] = bbox (x) index to hit boundary first   
   */
  static float[] blocks(Boundary b, Actor a, float[] bbox)
  {
    // we don't block in the pass-through direction.
    if(b.allowPassThrough(a.ix, a.iy)) { return null; }

    float[] current = bbox,
            previous = a.previous.getBoundingBox(),
            line = {b.x, b.y, b.xw, b.yh};

    return CollisionDetection.getLineRectIntersection(line, current, previous);
  }


  /**
   * The correction moves the bounding box to a safe location on the boundary,
   * but this might not be the correct location given the sprite inside the
   * bounding box. In order to make things look 'right', we examine the bounding
   * box to see by how much we can decrease the correction so that it looks as
   * if the sprite is anchored to the boundary.
   *
   * Does not return anything. The correction array is modified in-place.
   */
  static void adjustForSpriteMask(Boundary b, Actor a, float[] bbox, float[] correction)
  {
    int corner = (int)correction[2];
    if (corner == -1) return; 

    int sx = (int) bbox[corner],
        sy = (int) bbox[corner+1],
        ex = (int) (bbox[corner] - a.ix),
        ey = (int) (bbox[corner+1] - a.iy),
        minx = (int) bbox[0],  // FIXME: this will be incorrect for rotated actors
        miny = (int) bbox[1];
    PImage mask = a.getSpriteMask();
    if (mask != null) {
      int[] distance = getPermissibleSpriteMaskShift(mask, sx,sy, ex,ey, minx,miny);
      correction[0] -= distance[0];
      correction[1] -= distance[1];
    }
  }


  /**
   * Find the safe distance by which we can move a sprite so that 
   * rather than having its corner touch a boundary, it will look
   * like the sprite's image touches the boundary instead.
   *
   * This uses Bresenham's line algorithm, with a
   * safety conditional to prevent infinite loops.
   */  
  static int[] getPermissibleSpriteMaskShift(PImage m, int x0, int y0, int x1, int y1, int minx, int miny)
  {
    int[] shift = {0,0};
    int sx = x0,
        sy = y0,
        dx = (int) abs(x1-x0),  // distance to travel
        dy = (int) abs(y1-y0),
        ax = (x0<x1) ? 1 : -1,  // x and y stepping values
        ay = (y0<y1) ? 1 : -1,
        imx = 0,                // x and y coordinate on the image mask
        imy = 0,
        err = dx-dy,
        // Conceptually you rely on "while(true)", but no one
        // should ever do that. Safety first: add a cutoff.
        // Verifying over a 65535 pixel line should be enough.
        safety = 0;
    while(safety++ < 0xFFFF) {
      // if we find a pixel in the mask that is not
      // transparent, we have found our safe distance.
      imx = x0-minx;
      imy = y0-miny;
      if(sketch.alpha(m.get(imx,imy)) > 0) {
        shift = new int[]{(x0-sx), (y0-sy)};
        return shift;
      }
      // We must stop when we've reached the end coordinate
      else if(x0==x1 && y0==y1) {
        return shift;
      }
      // continue: move to the next pixel
      int e2 = err<<1;
      if(e2 > -dy) { err -= dy; x0 += ax; }
      if(e2 < dx) { err += dx; y0 += ay; }
    }
    // This code is unreachable, but ONLY in theory.
    // We could still get here if the cutoff is reached.
    return shift;
  }


// =================================================================

  // recycled containers
  private static float[] current_dots = {0,0,0,0,0,0,0,0};
  private static float[] previous_dots = {0,0,0,0,0,0,0,0};
  private static ArrayList<float[]> intersections = new ArrayList<float[]>();
  private static float[] checkLines = {0,0,0,0,0,0,0,0};
  private static float[] ZERO_DIFFERENCE = {0,0,-1};


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
   *
   * DOCUMENTATION FIX: we can actually treat 2 and 3 as the same case, with
   *                    a more reliable result, by always constructing a 
   *                    new intersection-validating parallelogram from the 
   *                    "hot corner" and an adjacent corner in {previous} and
   *                    {current}.
   *
   *
   * @return null if no intersect, otherwise float[3]
   *         indices: [0] = dx, [1] = dy, [2] = bbox (x) index to hit boundary first   
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
      //
      // FIXME: that said, if we treat (2) as a subset
      //        of (3), things seem to work better.
      checkLines = new float[8];
      arrayCopy(current,0,checkLines,0,8);

      currentCase = 3;

      // two of these edges are guaranteed to not have intersections,
      // since otherwise the intersection would be inside either
      // [previous] or [current], which is case (2) instead.
      checkLines = new float[]{previous[(corner)%8], previous[(corner+1)%8],
                               previous[(corner+2)%8], previous[(corner+3)%8],
                               current[(corner+2)%8],  current[(corner+3)%8],
                               current[(corner)%8],  current[(corner+1)%8]};

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

      // get the supposed hit-line
      float px = previous[corner],
            py = previous[corner+1],
            cx = current[corner],
            cy = current[corner+1];

      // if we have two intersections, it's
      // relatively easy to determine by how
      // much we should move back.
      if (intersectionCount == 2)
      {
        float[] i1 = intersections.get(0),
                 i2 = intersections.get(1);
        float[] ideal = getLineLineIntersection(px,py,cx,cy, i1[0],i1[1],i2[0],i2[1], false);
        if (ideal == null) { 
          if(debug) println("error: could not find the case "+currentCase+" ideal point based on corner ["+corner+"]");
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
          return new float[]{px-cx, py-cy, corner}; 
        }
        return new float[]{ideal[0]-cx, ideal[1]-cy, corner};
      }

      // if there's only one intersection,
      // additional math is required.
      else if (intersectionCount == 1)
      {
        float[] ideal = getLineLineIntersection(px,py,cx,cy, ox,oy,tx,ty, false);
        // this might fail, because it's not necessarily the "hot corner"
        // that ends up touching the boundary if we only have one intersection
        int cv = 0;
        for(cv = 2; cv<8 && ideal==null; cv+=4) {
          px = previous[(corner+cv)%8];
          py = previous[(corner+cv+1)%8];
          cx = current[(corner+cv)%8];
          cy = current[(corner+cv+1)%8];
          ideal = getLineLineIntersection(px,py,cx,cy, ox,oy,tx,ty, false);
        }

        // If ideal is still null, something very curious has happened.
        // Intersections occurred, but none of the corner paths are
        // involved. To the best of my knowledge this is algorithmically
        // impossible. Still, always good to see if I'm wrong:
        if(ideal==null) {
          if(debug) println("error: intersections occurred, but none of the corners were involved!");
          return new float[]{px-cx, py-cy, corner};
        }

        // return the delta and relevant corner
        return new float[]{ideal[0]-cx, ideal[1]-cy, (corner+cv)%8};
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
    float epsilon = 0.1;
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
