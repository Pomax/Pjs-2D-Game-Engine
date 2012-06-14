/***********************************
 *                                 *
 *     This file does nothing,     *
 *    but allows Processing to     *
 *     actually load the code      *
 *    if located in a directory    *
 *     of the same name. Feel      *
 *       free to rename it.        * 
 *                                 *
 ***********************************/
 

/* @ p j s  preload="docs/tutorial/graphics/mario/small/Standing-mario.gif"; */

///*

final int screenWidth = 512;
final int screenHeight = 432;
void initialize() { 
  addLevel("test", new TestLevel(width,height)); 
}

class TestLevel extends Level {
  TestLevel(float w, float h) {
    super(w,h); 
    addLevelLayer("test", new TestLayer(this,w,h));
  }
  
  void draw() {
    fill(0,1);
    rect(-1,-1,width+2,height+2);
    super.draw();
    stroke(0,255,0,150);
    line(width/2,0,width/2,height);
    line(width/2+16,0,width/2+16,height);
  }
}

class TestLayer extends LevelLayer {
  TestObject t1, t2, t3, t4;
  TestLayer(Level p, float w, float h) {
    super(p,w,h); 
    showBoundaries = true;

    t1 = new TestObject(width/4, height/4);
    t1.setForces(5,0);

    t2 = new TestObject(width/4, 3*height/4);
    t2.setForces(0,-5);

    t3 = new TestObject(3*width/4, 3*height/4);
    t3.setForces(-5,0);

    t4 = new TestObject(3*width/4, height/4);
    t4.setForces(0,5);

//    addPlayer(t1);
    addPlayer(t2);
//    addPlayer(t3);
//    addPlayer(t4);

    addBoundary(new Boundary(width/2+230,height,width/2+200,0));
    addBoundary(new Boundary(width/2-180,0,width/2-150,height));
    
    addBoundary(new Boundary(width,height/2-200,0,height/2-120));
    addBoundary(new Boundary(0,height/2+200,width,height/2+120));

    addBoundary(new Boundary(width/2,height/2,width/2 + 16,height/2));
  }

  void draw() { 
    super.draw();
    
    if (t1.getX() > 0.75*width)      { t1.setForces(-5,0); }
    else if (t1.getX() < 0.25*width) { t1.setForces(5,0); }

    if (t3.getX() > 0.75*width)      { t3.setForces(-5,0); }
    else if (t3.getX() < 0.25*width) { t3.setForces(5,0); }

    if (t2.getY() > 0.75*height)      { t2.setForces(0,-5); }
    else if (t2.getY() < 0.25*height) { t2.setForces(0,5); }

    if (t4.getY() > 0.75*height)      { t4.setForces(0,-5); }
    else if (t4.getY() < 0.25*height) { t4.setForces(0,5); }
  }
  
  void mouseClicked(int mx, int my, int mb) {
    if(mb==RIGHT) { noLoop(); return; }
    boundaries.clear();
    addBoundary(new Boundary(width/2, height/2, mx, my));
  }
}

class TestObject extends Player {
  TestObject(float x, float y) {
    super("test");
    addState(new State("test","docs/tutorial/graphics/mario/small/Standing-mario.gif"));
    setPosition(x,y);
  }
}

//*/
