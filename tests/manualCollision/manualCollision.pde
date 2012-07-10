final int screenWidth = 512;
final int screenHeight = 512;

float[] previous, current;
ArrayList<Boundary> boundaries;

void initialize() {
  SoundManager.mute(false);
  frameRate(30);
  boundaries = new ArrayList<Boundary>();
/*
  int xa = width/2 - 10,
      ya = height/2 - 10,
      xb = width/2 + 10,
      yb = height/2 + 10;
     
  boundaries.add( new Boundary(xa,ya, xb,ya) );
  boundaries.add( new Boundary(xb,ya, xb,yb) );
//  boundaries.add( new Boundary(xb,yb, xa,yb) );
//  boundaries.add( new Boundary(xa,yb, xa,ya) );
  
  previous = makeBox(xa,ya-19.9);
  current = makeBox(width,height);
*/
 
  boundaries.add(new Boundary(-32,384,1824,384));
  previous = new float[]{400, 367.9, 416, 367.9, 416, 383.9, 400, 383.9};
  current = new float[]{402, 371.9, 418, 371.9, 418, 387.9, 402, 387.9};
}

float[] makeBox(float x, float y) {
  return new float[]{ x-20,y-20, x+20,y-20, x+20,y+20, x-20,y+20};
}

void draw() {
  // check for collision
  int collision;
  for(collision = 0; collision<boundaries.size(); collision++) {
    Boundary b = boundaries.get(collision);
    float[] v = CollisionDetection.getLineRectIntersection(new float[]{b.x, b.y, b.xw, b.yh}, previous, current);
    if(v!= null) {
      println("collision on boundary "+collision+" - "+v[0]+"/"+v[1]+" correction required.");
      break;
    }
  }
  // red if collided, green if safe
  println("*** "+collision);
  if(collision>=boundaries.size()) { background(0,200,0); } else { background(200,0,0); }

  for(int b = 0; b<boundaries.size(); b++) {
    Boundary boundary = boundaries.get(b);
    boundary.draw(0,0,width,height);
  }  
  drawBox(previous, 100);
  drawBox(current, 200);

}

void drawBox(float[] bbox, float density) {
  fill(0,density);
  beginShape();
  vertex(bbox[0], bbox[1]);
  vertex(bbox[2], bbox[3]);
  vertex(bbox[4], bbox[5]);
  vertex(bbox[6], bbox[7]);
  endShape(CLOSE);
}

void mouseDragged() {
  float[] bbox = makeBox(mouseX, mouseY);
  if(mouseButton==LEFT) {
    previous = bbox;
  } else {
    current = bbox;
  }
  redraw();
}
