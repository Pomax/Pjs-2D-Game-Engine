void drawBoundingBox(float[] bounds) {
  stroke(255);
  fill(0,50);
  beginShape();
  vertex(bounds[0],bounds[1]);
  vertex(bounds[2],bounds[3]);
  vertex(bounds[4],bounds[5]);
  vertex(bounds[6],bounds[7]);
  endShape(); 
}