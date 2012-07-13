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

/*

final int screenWidth = 512;
final int screenHeight = 432;
void initialize() { 
  addScreen("test", new TestLevel(width,height)); 
}

class TestLevel extends Level {
  TestLevel(float w, float h) {
    super(w,h); 
    addLevelLayer("test", new TestLayer(this));
  }
  
  void draw() {
    fill(0,10);
    rect(-1,-1,width+2,height+2);
    super.draw();
  }
}

class TestLayer extends LevelLayer {
  TestObject t1;
  
  TestLayer(Level p) {
    super(p,p.width,p.height); 
    showBoundaries = true;
    
    int v = 10;

    t1 = new TestObject(width/2+v/2, height/2-210);
    t1.setForces(5,0);
    
    t1.setForces(0,0.01);
    t1.setAcceleration(0,0.1);

    addPlayer(t1);

    addBoundary(new Boundary(width/2+230,height,width/2+200,0));
    addBoundary(new Boundary(width/2-180,0,width/2-150,height));   
    addBoundary(new Boundary(width,height/2-200,0,height/2-120));
    addBoundary(new Boundary(0,height/2+200,width,height/2+120));

    //addBoundary(new Boundary(width/2,height/2,width/2 + v,height/2));
  }

  void draw() {
    super.draw();
    viewbox.track(parent,t1);
  }
}

class TestObject extends Player {
  boolean small = true;
  
  TestObject(float x, float y) {
    super("test");
    addState(new State("test","docs/tutorial/graphics/mario/small/Standing-mario.gif"));
    setPosition(x,y);
    Decal attachment = new Decal("static.gif",width,0);
    addDecal(attachment);
  }
  
  void addState(State s) {
    s.sprite.anchor(CENTER, BOTTOM);
    super.addState(s);
  }
  
  void keyPressed(char key, int keyCode) {
    if(small) {
      addState(new State("test","docs/tutorial/graphics/mario/big/Standing-mario.gif"));
    }
    else {
      addState(new State("test","docs/tutorial/graphics/mario/small/Standing-mario.gif"));
    }
    small = !small; 
  }
}

*/
