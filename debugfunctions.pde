
  /**
   * Debug function for drawing bounding boxes to the screen.
   */
  static void debugfunctions_drawBoundingBox(float[] bounds, PApplet sketch) {
    sketch.stroke(255,0,0);
    sketch.fill(0,50);
    sketch.beginShape();
    for(int i=0, last=bounds.length; i<last; i+=2) {
      sketch.vertex(bounds[i],bounds[i+1]);
    }
    sketch.endShape(CLOSE); 
  }


  /**
   * Draw a nice looking grid
   */
  void debugfunctions_drawBackground(float width, float height) {
    background(255,255,252);
    strokeWeight(1);
    fill(0);
    // fine grid
    stroke(235);
    float x, y;
    for (x = -width; x < width; x += 10) {
      line(x,-height,x,height); }
    for (y = -height; y < height; y += 10) {
      line(-width,y,width,y); }
    // coarse grid
    stroke(208);
    for (x = -width; x < width; x += 100) {
      line(x,-height,x,height); }
    for (y = -height; y < height; y += 100) {
      line(-width,y,width,y); }
    // reset to black
    stroke(0);
  }
