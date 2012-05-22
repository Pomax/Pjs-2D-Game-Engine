/**
 * Draw a nice looking grid
 */
void drawBackground(float width, float height) {
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
