/* @pjs preload="resources/mario/small/Standing-mario.gif"; */

float x_force = 0, y_force = 0;
float x_acceleration = 0, y_acceleration = 0;
Level lvl;

void setup() {
  size(300,300);
  SpriteMapHandler.setSketch(this);
  lvl = new EditorLevel(width,height);
}

void draw() {
  lvl.draw();
}

void addMySprite(float x, float y) {
  MySprite m = new MySprite(x, y);
  m.setForces(x_force, y_force);
  m.setAcceleration(x_acceleration, y_acceleration);
  lvl.addPlayer(m);

  MyNemesis n = new MyNemesis(x, y);
  n.setForces(x_force, y_force);
  n.setAcceleration(x_acceleration, y_acceleration);
  lvl.addInteractor(n);
}

void keyPressed() { lvl.keyPressed(key,keyCode); }
void keyReleased() { lvl.keyReleased(key,keyCode); }

void mouseClicked() {
  addMySprite(mouseX, mouseY);
}

class EditorLevel extends Level {
  EditorLevel(float w, float h) {
    super(w,h);
    // make debuggable
    debug = true;
    // set viewbox
    setViewBox(0,0,w,h);
    // add boundaries so we don't fall through
    addBoundary(new Boundary(w, 10, 0, 10));
    addBoundary(new Boundary(0, h-10, w, h-10));
    addBoundary(new Boundary(10, 0, 10, h));
    addBoundary(new Boundary(w-10, h, w-10, 0));
    // also add inner boundaries to bounce against
    addBoundary(new Boundary(w/2-50,h/2-50,w/2+50,h/2-50));
    addBoundary(new Boundary(w/2+50,h/2+50,w/2-50,h/2+50));
    addBoundary(new Boundary(w/2-50,h/2+50,w/2-50,h/2-50));
    addBoundary(new Boundary(w/2+50,h/2-50,w/2+50,h/2+50));
    // set up prototyping view   
    showBackground = false;
    showBoundaries = true;
  }
  
  void draw() {
    super.draw();
    noStroke();
    fill(0,0,255,25);
    rect(10,10,width-20,height/2-60);
    rect(10,height/2+50,width-20,height/2-60);
    rect(10,height/2-50,width/2-60, 100);
    rect(width/2+50,height/2-50,width/2-60, 100);
  }
}
