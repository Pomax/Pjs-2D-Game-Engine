// ====== LET'S GET OUR NINTENDO ON! ======

Level level;

/**
 * Test the actor class
 */
void setup()
{
  size(512,432);
  frameRate(24);
  SpriteMapHandler.setSketch(this);
  level = new TestLevel();
}

/**
 * Render mario in glorious canvas definition
 */
void draw() {
  level.draw();
}

// pass-through keyboard events
void keyPressed() { level.keyPressed(key,keyCode); }
void keyReleased() { level.keyReleased(key, keyCode); }
void mousePressed() { level.mousePressed(mouseX, mouseY); }

// ======================


// test the engine mechanics
class TestLevel extends Level {
  PImage bg = loadImage("graphics/backgrounds/sky.png");
  TilingSprite groundline;
  TilingSprite groundfiller;
  Sprite groundslant;
  Actor actor;

  /**
   * Test the actor class
   */
  TestLevel()
  {
    // screen boundaries
    float pad = 10;
//    boundaries.add(new Boundary(width-pad,pad,pad,pad));
//    boundaries.add(new Boundary(width-pad,height-pad,width-pad,pad));
//    boundaries.add(new Boundary(pad,pad,pad,height-pad));

    Sprite groundsprite = new Sprite("graphics/backgrounds/ground-top.png", 1, 1);
    groundline = new TilingSprite(groundsprite, 0,height-40, 2*width, height - 40 + groundsprite.height);

    Sprite groundfillsprite = new Sprite("graphics/backgrounds/ground-filler.png", 1, 1);
    groundfiller = new TilingSprite(groundfillsprite, 0,height-40 + groundsprite.height, 2*width, height);

    boundaries.add(new Boundary(-pad,height-48,width+pad,height-48));

    // clouds!
    boundaries.add(new Boundary(54, 96, 105, 96));
    boundaries.add(new Boundary(54 + 224, 96 +  48, 105 + 224, 96 +  48));
    boundaries.add(new Boundary(54 + 336, 96 +  32, 105 + 336, 96 +  32));
    boundaries.add(new Boundary(54 + 256, 96 + 192, 105 + 256, 96 + 192));
    boundaries.add(new Boundary(54 + 336, 96 + 208, 105 + 336, 96 + 208));
    //boundaries.add(new Boundary(54 + 170, 96 + 240, 105 + 176, 96 + 240));
    boundaries.add(new Boundary(54 + 138, 96 + 144, 105 + 112, 96 + 144));
    boundaries.add(new Boundary(54 + 186, 96 + 160, 105 + 160, 96 + 160));
    boundaries.add(new Boundary(54 + 330, 96 + 256, 105 + 322, 96 + 256));

    Sprite groundslant = new Sprite("graphics/backgrounds/ground-slant.png",1,1);
    groundslant.align(RIGHT,TOP);
    groundslant.setPosition(width/2, height - groundslant.height - 48);
    npss.add(groundslant);

    boundaries.add(new Boundary(width/2, height - groundslant.height, width/2 + 48, height - groundslant.height - 48));

    // test actor
    actor = new Mario();
    actor.setPosition(width/2,height/2);
    actor.setForces(0,1);
    actors.add(actor);
  }


  /**
   * Render mario in glorious canvas definition
   */
  void draw()
  {
    background(0,100,190);
    image(bg,0,0);
    groundline.draw();
    groundfiller.draw();

    // draw level the standard way
    super.draw();
    actor.x = (actor.x + width) % width;
  }

  void mousePressed(int mx, int my) {
    Actor koopa = new Koopa();
    resetMatrix();
    koopa.setPosition(width/2, height/2);
    koopa.setForces(-0.2,1);
    npas.add(koopa);
  }
}

/**
 * Mario, that lovable, portly, moustachioed man.
 */
class Mario extends Actor {

  float speedStep = 1.3;
  float speedHeight = 19;

  Mario() {
    super(0.8, 0.8);
    
    String sizeSet = "small";

    // when not moving
    State standing = new State("standing","graphics/mario/"+sizeSet+"/Standing-mario.png",1,1);
    standing.sprite.align(CENTER, BOTTOM);
    addState(standing);

    // when either pressing right or left
    State running = new State("running","graphics/mario/"+sizeSet+"/Running-mario.png",1,4);
    running.sprite.align(CENTER, BOTTOM);
    running.sprite.setAnimationSpeed(0.75);
    addState(running);

    // when [down] is pressed
    State crouching = new State("crouching","graphics/mario/"+sizeSet+"/Crouching-mario.png",1,1);
    crouching.sprite.align(CENTER, BOTTOM);
    addState(crouching);
  
    // when pressing up   
    State looking = new State("looking","graphics/mario/"+sizeSet+"/Looking-mario.png",1,1);
    looking.sprite.align(CENTER, BOTTOM);
    addState(looking);

    // when pressing the A button
    State jumping = new State("jumping","graphics/mario/"+sizeSet+"/Jumping-mario.png",1,1);
    jumping.sprite.align(CENTER, BOTTOM);
    addState(jumping);

    // when pressing the A button while small
    State crouchjumping = new State("crouchjumping","graphics/mario/"+sizeSet+"/Crouching-mario.png",1,1);
    crouchjumping.sprite.align(CENTER, BOTTOM);
    addState(crouchjumping);

    // when pressing the B button
    State spinning = new State("spinning","graphics/mario/"+sizeSet+"/Spinning-mario.png",1,4);
    spinning.sprite.align(CENTER, BOTTOM);
    addState(spinning);
    
    // start off using the "standing" sprite
    setCurrentState("standing");
  }

  void handleInput() {
   if (active != getState("crouching") && active != getState("looking")) {
     if (keyDown[LEFT]  || keyDown[cLEFT]) { 
        setHorizontalFlip(true); 
        addImpulse(-speedStep, 0);
      }
      if (keyDown[RIGHT] || keyDown[cRIGHT]) { 
        setHorizontalFlip(false); 
        addImpulse( speedStep, 0);
      }
    }

    if (keyDown[BUTTON_A]) {
      if (active.name != "jumping" && active.name != "crouchjumping" && active.name != "spinning") {
        detach();
        addImpulse(0,speedHeight*-speedStep);
        if (active.name == "crouching") { setCurrentState("crouchjumping"); }
        else { setCurrentState("jumping"); }
      }
    }
    else if (keyDown[BUTTON_B]) {
      if (active.name != "jumping" && active.name != "crouchjumping" && active.name != "spinning") {
        detach();
        addImpulse(0,speedHeight*-speedStep);
        setCurrentState("spinning"); 
      }
    }
    else if (keyDown[DOWN]) { 
      setCurrentState("crouching");
    }
    else if (keyDown[UP]) { 
      setCurrentState("looking");
    }
    else if (keyDown[LEFT] || keyDown[RIGHT]) { 
      setCurrentState("running");
    } 
    else { setCurrentState("standing"); }

  }

  void handleStateFinished(State which) {
    // does nothing
  }
}

/**
 * Koopa trooper test
 */
class Koopa extends Actor {

  float speedStep = 1.3;
  float speedHeight = 19;

  Koopa() {
    super(0.8, 0.8);

    // koopa has one state at the moment.
    State walking = new State("walking","graphics/enemies/Red-koopa-walking.png",1,2);
    walking.sprite.align(CENTER, BOTTOM);
    walking.sprite.setAnimationSpeed(0.25); 
    addState(walking);

    // start off using the "standing" sprite
    setCurrentState("walking");
  }

  void handleInput() {
    // does nothing
  }

  void handleStateFinished(State which) {
    // does nothing
  }
}
