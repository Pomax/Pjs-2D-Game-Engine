/**
 * The Sprite path chunker is capable of taking a curved
 * path over X frames, and return the list of coordinates
 * on that curve that correspond to X-1 equidistant segments.
 *
 * It uses the Legendre-Gauss quadrature algorithm for
 * finding the approximate arc length of a curves, which
 * is incredibly fast, and ridiculously accurate at n=25
 *
 */
static class SpritePathChunker {

  // Legendre-Gauss abscissae for n=25
  static final float[] Tvalues = {-0.0640568928626056299791002857091370970011,
                       0.0640568928626056299791002857091370970011,
                      -0.1911188674736163106704367464772076345980,
                       0.1911188674736163106704367464772076345980,
                      -0.3150426796961633968408023065421730279922,
                       0.3150426796961633968408023065421730279922,
                      -0.4337935076260451272567308933503227308393,
                       0.4337935076260451272567308933503227308393,
                      -0.5454214713888395626995020393223967403173,
                       0.5454214713888395626995020393223967403173,
                      -0.6480936519369755455244330732966773211956,
                       0.6480936519369755455244330732966773211956,
                      -0.7401241915785543579175964623573236167431,
                       0.7401241915785543579175964623573236167431,
                      -0.8200019859739029470802051946520805358887,
                       0.8200019859739029470802051946520805358887,
                      -0.8864155270044010714869386902137193828821,
                       0.8864155270044010714869386902137193828821,
                      -0.9382745520027327978951348086411599069834,
                       0.9382745520027327978951348086411599069834,
                      -0.9747285559713094738043537290650419890881,
                       0.9747285559713094738043537290650419890881,
                      -0.9951872199970213106468008845695294439793,
                       0.9951872199970213106468008845695294439793};

  // Legendre-Gauss weights for n=25
  static final float[] Cvalues = {0.1279381953467521593204025975865079089999,
                      0.1279381953467521593204025975865079089999,
                      0.1258374563468283025002847352880053222179,
                      0.1258374563468283025002847352880053222179,
                      0.1216704729278033914052770114722079597414,
                      0.1216704729278033914052770114722079597414,
                      0.1155056680537255991980671865348995197564,
                      0.1155056680537255991980671865348995197564,
                      0.1074442701159656343712356374453520402312,
                      0.1074442701159656343712356374453520402312,
                      0.0976186521041138843823858906034729443491,
                      0.0976186521041138843823858906034729443491,
                      0.0861901615319532743431096832864568568766,
                      0.0861901615319532743431096832864568568766,
                      0.0733464814110802998392557583429152145982,
                      0.0733464814110802998392557583429152145982,
                      0.0592985849154367833380163688161701429635,
                      0.0592985849154367833380163688161701429635,
                      0.0442774388174198077483545432642131345347,
                      0.0442774388174198077483545432642131345347,
                      0.0285313886289336633705904233693217975087,
                      0.0285313886289336633705904233693217975087,
                      0.0123412297999872001830201639904771582223,
                      0.0123412297999872001830201639904771582223};

  /**
   * Naive time parameterisation based on frame duration.
   * 1) calculate total length of curve
   * 2) calculate required equidistant segment length
   * 3) run through curve using small time interval
   *    increments and record at which [t] a new segment
   *    starts.
   * 4) the resulting list is our time parameterisation.
   */
  static float[] getTimeValues(float x1, float y1, float x2, float y2, float x3, float y3, float x4, float y4, float frames) {
    float curvelen = computeCubicCurveLength(1.0,x1,y1,x2,y2,x3,y3,x4,y4),
          seglen = curvelen/frames,
          seglen10 = seglen/10,
          t,
          increment=0.01,
          curlen = 0,
          prevlen = 0;

    // before we do the real run, find an appropriate t increment
    while (computeCubicCurveLength(increment,x1,y1,x2,y2,x3,y3,x4,y4) > seglen10) {
      increment /= 2.0;
    }

    // now that we have our step value, we simply run through the curve:
    int alen = (int)frames;
    float len[] = new float[alen];
    float trp[] = new float[alen];
    int frame = 1;
    for (t = 0; t < 1.0 && frame<alen; t += increment) {
      // get length of curve over interval [0,t]
      curlen = computeCubicCurveLength(t,x1,y1,x2,y2,x3,y3,x4,y4);

      // Did we run past the acceptable segment length?
      // If so, record this [t] as starting a new segment.
      while(curlen > frame*seglen) {
        len[frame] = curlen;
        trp[frame++] = t;
        prevlen = curlen;
      }
    }

    // Make sure that any gaps left at the end of the path are filled with 1.0
    while(frame<alen) { trp[frame++] = 1.0; }
    return trp;
  }

  /**
   * Gauss quadrature for cubic Bezier curves. See
   *
   *   http://processingjs.nihongoresources.com/bezierinfo/#intoffsets_gss
   *
   * for a more detailed explanation on why this is
   * the right way to compute the arc length of a curve.
   */
  private static float computeCubicCurveLength(float z, float x1, float y1, float x2, float y2, float x3, float y3, float x4, float y4)
  {
    float sum = 0;
    int tlen = Tvalues.length;
    float z2 = z/2.0;  // interval-correction
    for(int i=0; i<tlen; i++) {
      float corrected_t = z2 * Tvalues[i] + z2;
      sum += Cvalues[i] * f(corrected_t,x1,y1,x2,y2,x3,y3,x4,y4); }
    return z2 * sum;
  }

  /**
   * This function computes the value of the function
   * that we're trying to compute the discrete integral
   * for (because we can't compute it symbolically).
   */
  private static float f(float t, float x1, float y1, float x2, float y2, float x3, float y3, float x4, float y4)
  {
    float xbase = ddtsqr(t,x1,x2,x3,x4);
    float ybase = ddtsqr(t,y1,y2,y3,y4);
    float combined = xbase*xbase + ybase*ybase;
    return sqrt(combined);
  }

  /**
   * This function computes (d/dt)² for the cubic Bezier function.
   */
  private static float ddtsqr(float t, float p1, float p2, float p3, float p4)
  {
    float t1 = -3*p1 + 9*p2 - 9*p3 + 3*p4;
    float t2 = t*t1 + 6*p1 - 12*p2 + 6*p3;
    return t*t2 - 3*p1 + 3*p2;
  }
}
