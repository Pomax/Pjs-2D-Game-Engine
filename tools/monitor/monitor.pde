/**
 * Framerate monitor
 */

final int xoff = 25;
int bin = 0;
int[] values = new int[100];

int actors = 0;

void addPoint(int v) {
  values[bin] = v;
  bin = (bin+1)%100;
  redraw();
}

void addActor() { actors++; }
void setActorCount(int v) { actors += v; }
void removeActor() { actors--; }
void resetActorCount() { actors = 0; }

void setup() {
  size(xoff+100,110);
  textFont(createFont("Arial",8));
}

void draw() {
  background(255);
  fill(0);
  stroke(127);
  textAlign(RIGHT);
  for(int i=0; i<100; i+=10) {
    line(xoff,i,xoff+100,i);
    text(""+i, xoff-10, 100 - i);
  }
  text("frame rate: "+(values[(bin-1)%100]|0), xoff+100, 109);
  textAlign(LEFT);
  text("Live actors: "+actors, 5, 109);
  noFill();
  stroke(0);
  rect(0,0,xoff+100,100);
  stroke(200,0,0);
  line(xoff,0,xoff,100);
  for(int b=0; b<100; b++) {
    point(xoff+b, 100-values[b]);
  }
  stroke(0,0,200);
  line(xoff+bin,0,xoff+bin,100);
}
