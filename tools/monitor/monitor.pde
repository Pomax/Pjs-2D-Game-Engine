/**
 * Framerate monitor
 */

final int xoff = 25, hlen = 100, vlen = 49;
int[] values;
int bin, actors;

void setup() {
  size(xoff+hlen,110);
  textFont(createFont("Arial",8));
  bin = 0;
  actors = 0;
  values = new int[hlen];
}

void draw() {
  background(255);

  // graph lining
  fill(0);
  stroke(127);
  textAlign(RIGHT);
  for(int i=0; i<vlen; i+=5) {
    int h = hlen - (i*height/vlen);
    line(xoff,h,xoff+hlen,h);
    text(""+i, xoff-10, h); }

  // text info  
  text("frame rate: "+(values[(bin-1)%hlen]|0), xoff+hlen, 109);
  textAlign(LEFT);
  text("Live actors: "+actors, 5, 109);

  // vertical axis
  noFill();
  stroke(0);
  line(xoff,0,xoff,100);

  // data plot, in red
  for(int b=0; b<100; b++) {
    int h = values[b]*height/vlen;  
    stroke(200,0,0);
    point(xoff+b, 100-h);
  }

  // draw 'current' as scanline
  stroke(0,0,200);
  line(xoff+bin,0,xoff+bin,100);
}

void addPoint(int v) {
  values[bin] = v;
  bin = (bin+1)%100;
  redraw();
}

void addActor() { actors++; }
void setActorCount(int v) { actors += v; }
void removeActor() { actors--; }
void resetActorCount() { actors = 0; }