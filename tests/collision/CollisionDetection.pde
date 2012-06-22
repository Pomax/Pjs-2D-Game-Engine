/**
 * Alternative collision detection
 */
static class CollisionDetection {
  private static boolean debug = false;

  /**
   * Static classes need global sketch binding
   */
  private static PApplet sketch;
  public static void init(PApplet s) { sketch = s; } 

  /**
   *
   */
  static float[] getLineRectIntersection(float[] line, float[] previous, float[] current)
  {
    float x1=line[0], y1=line[1], x2=line[2], y2=line[3];
    float dx = x2-x1, dy = y2-y1, pv=PI/2.0,
          rdx = dx*cos(pv) - dy*sin(pv),
          rdy = dx*sin(pv) + dy*cos(pv);

    // determine range w.r.t. the starting point of the boundary.
    float[] dotProducts1 = getDotProducts(x1,y1,x2,y2, previous);

    // determine range w.r.t. the end point of the boundary.
    float[] dotProducts2 = getDotProducts(x2,y2,x1,y1, previous);

    // determine sidedness relative to the boundary.
    float[] dotProducts3 = getDotProducts(x1,y1,x1+rdx,y1+rdy, previous);
    float[] dotProducts4 = getDotProducts(x1,y1,x1+rdx,y1+rdy, current);

    // determine the three aspects:
    int inRangeS = 4, inRangeE = 4, above = 0, aboveAfter = 0;
    for(int i=0; i<8; i+=2) {
      if(dotProducts1[i]<0) { inRangeS--; }
      if(dotProducts2[i]<0) { inRangeE--; }
      if(dotProducts3[i]<0) { above++; }
      if(dotProducts4[i]<0) { aboveAfter++; }}

    // make sure to short-circuit if we're out of bounds
    if (inRangeS == 0 || inRangeE == 0 || above<4) return null;

    // has a collision been detected?
    boolean found = false;

    // We're in bounds. if above is 4 and aboveAfter is 0,
    // we need to perform special collision detection
    if (above==4 && aboveAfter==0) {
      println("full containment if we use boundary box");
      found = true;
    }

    else {
      // We're in bounds. Rather than checking whether
      // we cross the boundary from previous->current,
      // we pretend the boundary moves, instead. This
      // allows us to do box/box intersection checking
      // instead using previous and the boundary-box.
      dx = previous[0] - current[0];
      dy = previous[1] - current[1];
      
      // form boundary box
      float[] bbox = {line[0], line[1],
                      line[2], line[3],
                      line[2]+dx, line[3]+dy,
                      line[0]+dx, line[1]+dy};
  
      sketch.stroke(0,200,0);
      drawBox(bbox);
      
      // do any of the "prev" edges intersect
      // with any of the "bbox" edges?
      int i,j;
      float[] p = previous, b = bbox, intersection;
      for(i=0; i<8; i+=2) {
        for(j=0; j<8; j+=2) {
          intersection = getLineLineIntersection(p[i], p[i+1], p[(i+2)%8], p[(i+3)%8], b[j], b[j+1], b[(j+2)%8], b[(j+3)%8], false, true);
          if (intersection != null) {
            found = true;
  
            sketch.stroke(255,0,255);
            sketch.ellipse(intersection[0],intersection[1],5,5);
            //sketch.line(intersection[0],intersection[1],intersection[0]-dx,intersection[1]-dy);
            sketch.noLoop();
          }
        }
      }
    }
    
    if (found) {
      float[] distances = getCornerDistances(x1,y1,x2,y2, previous, current);
      int[] corners = rankCorners(distances);
      int corner = 0;
      float x,y;
      x = previous[corners[corner]];
      y = previous[corners[corner]+1];

      sketch.stroke(255,0,0);
      sketch.ellipse(x,y,5,5);

      float[] intersection = getLineLineIntersection(line[0],line[1],line[2],line[3], x,y,x-dx,y-dy, false, true);

      if (intersection==null) {
        println("nearest-to-boundary is actually not on the boundary itself. More complex math is required!");
        
        float sdx = line[2]-line[0], sdy = line[3]-line[1];      
        intersection = getLineLineIntersection(line[0]-sdx,line[1]-sdy,line[2]+sdx,line[3]+sdy, x,y,x-dx,y-dy, false, true);

        sketch.stroke(0,0,200);
        sketch.line(line[0]-sdx,line[1]-sdy,line[2]+sdx,line[3]+sdy);

        if (intersection==null) {
          println("line extension alone is not enoough...");
          return null;
        }
        return new float[]{intersection[0] - current[corners[corner]], intersection[1] - current[corners[corner]+1]};
      }

      sketch.stroke(0,255,255);
      sketch.ellipse(intersection[0],intersection[1],5,5);
      sketch.stroke(150,150,200);
      drawBox(current);
      
      return new float[]{intersection[0] - current[corners[corner]], intersection[1] - current[corners[corner]+1]};
    }

    return null;
  }
  
  /**
   * 
   */
  static float[] getCornerDistances(float x1, float y1, float x2, float y2, float[] previous, float[] current) {
    float[] distances = {0,0,0,0,0,0,0,0}, intersection;
    float dx, dy;
    for(int i=0; i<8; i+=2) {
      intersection = getLineLineIntersection(x1,y1,x2,y2, previous[i], previous[i+1], current[i], current[i+1], false, false);
      //sketch.ellipse(intersection[0],intersection[1],3,3);
      //sketch.line(intersection[0],intersection[1],intersection[0]+1000,intersection[1]);
      dx = intersection[0] - previous[i];
      dy = intersection[1] - previous[i+1];
      distances[i] = sqrt(dx*dx+dy*dy);
      distances[i+1] = distances[i];
    }
    return distances;
  }
  
  
  /**
   * Get the intersection coordinate between two lines segments.
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
   * bounding box, and a boundary line with origin ox/oy.
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
      dotProducts[i]   = dotproduct;
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
  static int[] rankCorners(float[] distances) {
    int[] corners = {0,0,0,0};
    float corner1v=999999, corner2v=corner1v, corner3v=corner1v, corner4v=corner1v, dotproduct;
    int   corner1=-1, corner2=-1, corner3=-1, corner4=-1;

    for(int i=0; i<8; i+=2) {
      dotproduct = distances[i];
      if(dotproduct<corner1v) { 
        corner4v = corner3v; corner3v = corner2v; corner2v = corner1v; corner1v = dotproduct;
        corner4 = corner3; corner3 = corner2; corner2 = corner1; corner1 = i; }
      else if(dotproduct<corner2v) {
        corner4v = corner3v; corner3v = corner2v; corner2v = dotproduct;
        corner4 = corner3; corner3 = corner2; corner2 = i; }
      else if(dotproduct<corner3v) {
        corner4v = corner3v; corner3v = dotproduct;
        corner4 = corner3; corner3 = i; }
      else { corner4v = dotproduct; corner4 = i; }
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
   * Check if a bouning box's dot product
   * information implies it's safe, or blocked.
   */
  static boolean permitted(float[] dotProducts) {
    for(int i=0; i<8; i+=2) {
      if (dotProducts[i]>0)
        return true; }
    return false;
  }
  
  
  /**
   * helper function
   */  
  static void drawBox(float[] bbox) {
    sketch.line(bbox[0], bbox[1], bbox[2], bbox[3]);
    sketch.line(bbox[2], bbox[3], bbox[4], bbox[5]);
    sketch.line(bbox[4], bbox[5], bbox[6], bbox[7]);
    sketch.line(bbox[6], bbox[7], bbox[0], bbox[1]);
  }
}
