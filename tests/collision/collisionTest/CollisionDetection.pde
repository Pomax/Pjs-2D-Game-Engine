/**
 * Alternative collision detection
 */
static class CollisionDetection {
  private static boolean debug = true;

  /**
   * Static classes need global sketch binding
   */
  private static PApplet sketch;
  public static void init(PApplet s) { sketch = s; } 

  /**
   * Perform line/rect intersection detection. Lines represent boundaries,
   * and rather than doing "normal" line/rect intersection using a
   * "box on a trajectory" that normal actor movement looks like, we pretend
   * the actor box remains stationary, and move the boundary in the opposite
   * direction with the same speed, which gives us a "boundary box", so that
   * we can perform box/box overlap detection instead.
   */
  static float[] getLineRectIntersection(float[] line, float[] previous, float[] current)
  {
    if(debug) sketch.println(sketch.frameCount + ">  testing against: "+arrayToString(line));
    if(debug) sketch.println(sketch.frameCount + ">   previous: "+arrayToString(previous));
    if(debug) sketch.println(sketch.frameCount + ">   current : "+arrayToString(current));

    // First, let's do some dot-product math, to find out whether or not
    // the actor's bounding box is even in range of the boundary.
    float x1=line[0], y1=line[1], x2=line[2], y2=line[3];
    float dx = x2-x1, dy = y2-y1, pv=PI/2.0,
          rdx = dx*cos(pv) - dy*sin(pv),
          rdy = dx*sin(pv) + dy*cos(pv);

    // determine range w.r.t. the starting point of the boundary.
    float[] dotProducts1 = getDotProducts(x1,y1,x2,y2, previous);

    // determine range w.r.t. the end point of the boundary.
    float[] dotProducts2 = getDotProducts(x2,y2,x1,y1, previous);

    // determine 'sidedness', relative to the boundary.
    float[] dotProducts3 = getDotProducts(x1,y1,x1+rdx,y1+rdy, previous);
    float[] dotProducts4 = getDotProducts(x1,y1,x1+rdx,y1+rdy, current);

    // compute the relevant feature values based on the dot products:
    int inRangeS = 4, inRangeE = 4, above = 0, aboveAfter = 0;
    for(int i=0; i<8; i+=2) {
      if (dotProducts1[i] < 0) { inRangeS--; }
      if (dotProducts2[i] < 0) { inRangeE--; }
      if (dotProducts3[i] <= 0) { above++; }
      if (dotProducts4[i] <= 0) { aboveAfter++; }}

    if(debug) sketch.println(sketch.frameCount +">    dotproduct result: "+inRangeS+"/"+inRangeE+"/"+above+"/"+aboveAfter);

    // make sure to short-circuit if the actor cannot
    // interact with the boundary because it is out of range.
    if (inRangeS == 0 || inRangeE == 0) {
      if(debug) sketch.println(sketch.frameCount +">   this boundary is not involved in collisions for this frame.");
      return null;
    }
    
    if (above>0 && aboveAfter>above) {
      if(debug) sketch.println(sketch.frameCount +">   this box is not involved in collisions for this frame (1).");
      return null;
    }
    
    if (above==4 && aboveAfter==4) {
      if(debug) sketch.println(sketch.frameCount +">   this box is not involved in collisions for this frame (2).");
      return null;
    }

    // Now then, let's determine whether overlap will occur.
    boolean found = false;

    // We're in bounds: if 'above' is 4, meaning that our previous
    // actor frame is on the blocking side of a boundary,  and
    // 'aboveAfter' is 0, meaning its current frame is on the other
    // side of the boundary, then a collision MUST have occurred.
    if (above==4 && aboveAfter==0) {
      // note that in this situation, the overlap may look
      // like full containment, where the actor's bounding
      // box is fully contained by the boundary's box.
      found = true;
      if(debug) sketch.println(sketch.frameCount +">     collision detected (due to full containment).");
    }

    else {
      // We're in bounds: do box/box intersection checking
      // using the 'previous' box and the boundary-box.
      dx = previous[0] - current[0];
      dy = previous[1] - current[1];
      
      // form boundary box
      float[] bbox = {line[0], line[1],
                      line[2], line[3],
                      line[2]+dx, line[3]+dy,
                      line[0]+dx, line[1]+dy};
      
      // do any of the "previous" edges intersect
      // with any of the "boundary box" edges?
      int i,j;
      float[] p = previous, b = bbox, intersection;
      for(i=0; i<8; i+=2) {
        for(j=0; j<8; j+=2) {
          intersection = getLineLineIntersection(p[i], p[i+1], p[(i+2)%8], p[(i+3)%8], b[j], b[j+1], b[(j+2)%8], b[(j+3)%8], false, true);
          if (intersection != null) {
            found = true;
            if(debug) sketch.println(sketch.frameCount +">     collision detected on a box edge (box overlap).");
          }
        }
      }
    }
    
    // Have we signaled any overlap?
    if (found) {
      float[] distances = getCornerDistances(x1,y1,x2,y2, previous, current);
      int[] corners = rankCorners(distances);

      if(debug) {
        sketch.print(sketch.frameCount + ">      ");
        for(int i=0; i<4; i++) {
          sketch.print(corners[i]+"="+distances[corners[i]]);
          if(i<3) sketch.print(", "); }
        sketch.println();
      }

      // Get the corner on the previous and current actor bounding
      // box that will "hit" the boundary first.
      int corner = 0;
      float xp = previous[corners[corner]],
            yp = previous[corners[corner]+1],
            xc = current[corners[corner]],
            yc = current[corners[corner]+1];

      // The trajectory for this point may intersect with
      // the boundary. If it does, we'll have all the information
      // we need to move the actor back along its trajectory by
      // an amount that will place it "on" the boundary, at the right spot.
      float[] intersection = getLineLineIntersection(xp,yp,xc,yc, x1,y1,x2,y2, false, true);

      if (intersection==null) {
        println("nearest-to-boundary is actually not on the boundary itself. More complex math is required!");

        // it's also possible that the first corner to hit the boundary
        // actually never touches the boundary because it intersects only
        // if the boundary is infinitely long. So... let's make that happen:
        intersection = getLineLineIntersection(xp,yp,xc,yc, x1,y1,x2,y2, false, false);

        if (intersection==null) {
          println("line extension alone is not enoough...");
          return null;
        }

        return new float[]{intersection[0] - xc, intersection[1] - yc};
      }
      
      // if we get here, there was a normal trajectory
      // intersection with the boundary. Computing the
      // corrective values by which to move the current
      // frame's bounding box is really simple:
      dx = intersection[0] - xc;
      dy = intersection[1] - yc;

      if(debug) sketch.println(sketch.frameCount +">      dx: "+dx+", dy: "+dy);

      return new float[]{dx, dy};
    }

    return null;
  }
  
  /**
   * For each corner in an object's bounding box, get the distance from its "previous"
   * box to the line defined by (x1,y1,x2,y2). Return this as float[8], corresponding
   * to the bounding box array format.
   */
  static float[] getCornerDistances(float x1, float y1, float x2, float y2, float[] previous, float[] current) {
    float[] distances = {0,0,0,0,0,0,0,0}, intersection;
    float dx, dy;
    for(int i=0; i<8; i+=2) {
      intersection = getLineLineIntersection(x1,y1,x2,y2, previous[i], previous[i+1], current[i], current[i+1], false, false);
      if (intersection == null) {
        continue;
      }
      dx = intersection[0] - previous[i];
      dy = intersection[1] - previous[i+1];
      distances[i] = sqrt(dx*dx+dy*dy);
      distances[i+1] = distances[i];
    }
    return distances;
  }
  
  
  /**
   * Get the intersection coordinate between two lines segments,
   * using fairly standard, if a bit lenghty, linear algebra.
   */
  static float[] getLineLineIntersection(float x1, float y1, float x2, float y2, float x3, float y3, float x4, float y4, boolean colinearity, boolean segments)
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
      if (segments && (x < min(x1, x2) - epsilon || max(x1, x2) + epsilon < x ||
                       y < min(y1, y2) - epsilon || max(y1, y2) + epsilon < y ||
                       x < min(x3, x4) - epsilon || max(x3, x4) + epsilon < x ||
                       y < min(y3, y4) - epsilon || max(y3, y4) + epsilon < y)) {
        // not on either, or both, segments.
        return null;
      }
      return new float[]{x, y};
    }
  }


  /**
   * compute the dot product between all corner points of a
   * bounding box, and a boundary line with origin ox/oy
   * and end point tx/ty.
   */
  static float[] getDotProducts(float ox, float oy, float tx, float ty, float[] bbox) {
    float dotx = tx-ox, doty = ty-oy,
          otlen = sqrt(dotx*dotx + doty*doty),
          dx, dy, len, dotproduct;
  
    dotx /= otlen;
    doty /= otlen;
    
    float[] dotProducts = new float[8];
  
    for(int i=0; i<8; i+=2) {
      dx = bbox[i]-ox;
      dy = bbox[i+1]-oy;
      len = sqrt(dx*dx+dy*dy);
      dx /= len;
      dy /= len;
      dotproduct = dx*dotx + dy*doty;
      dotProducts[i] = dotproduct;
    }
  
    return dotProducts;
  }


  /**
   * Rank the corner points for a bounding box
   * based on it's distance to the boundary,
   * along its trajectory path.
   *
   * We rank by decreasing distance.
   */
  // FIXME: this is a pretty fast code, but there might be
  //        better ways to achieve the desired result.
  static int[] rankCorners(float[] distances) {
    int[] corners = {0,0,0,0};
    float corner1v=999999, corner2v=corner1v, corner3v=corner1v, corner4v=corner1v, distance;
    int   corner1=-1, corner2=-1, corner3=-1, corner4=-1;

    for(int i=0; i<8; i+=2) {
      distance = distances[i];
      if (distance < corner1v) { 
        corner4v = corner3v;  corner4 = corner3;
        corner3v = corner2v;  corner3 = corner2;
        corner2v = corner1v;  corner2 = corner1;
        corner1v = distance;  corner1 = i; 
        continue; }
      if (distance < corner2v) {
        corner4v = corner3v;  corner4 = corner3;
        corner3v = corner2v;  corner3 = corner2;
        corner2v = distance;  corner2 = i;
        continue; }
      if (distance < corner3v) {
        corner4v = corner3v;  corner4 = corner3;
        corner3v = distance;  corner3 = i;
        continue; }
      corner4v = distance;  corner4 = i;
    }

    // Set up the corners, ranked by
    // proximity to the boundary.
    corners[0] = corner1;
    corners[1] = corner2;
    corners[2] = corner3;
    corners[3] = corner4;
    return corners;
  }


  /**
   * Check if a bounding box's dot product
   * information implies it's safe, or blocked.
   */
  static boolean permitted(float[] dotProducts) {
    for(int i=0; i<8; i+=2) {
      if (dotProducts[i]>0)
        return true; }
    return false;
  }


  /**
   * Simple drawing helper function
   */
  static void drawBox(float[] boundingbox) {
    sketch.line(boundingbox[0], boundingbox[1], boundingbox[2], boundingbox[3]);
    sketch.line(boundingbox[2], boundingbox[3], boundingbox[4], boundingbox[5]);
    sketch.line(boundingbox[4], boundingbox[5], boundingbox[6], boundingbox[7]);
    sketch.line(boundingbox[6], boundingbox[7], boundingbox[0], boundingbox[1]);
  }

  /**
   * Simple printing helper function
   */
  static String arrayToString(float[] arr) {
    String str = "";
    for(int i=0; i<arr.length; i++) {
      str += int(100*arr[i])/100.0;
      if(i<arr.length-1) { str += ", "; }}
    return str;
  }  
}
