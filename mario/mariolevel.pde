/**
 * a level in a mario game
 */
class MarioLevel extends Level {
  Player mario;
  String wintext = "Goal!";
  int endCount = 0;

  MarioLevel(float w, float h) { 
    super(w, h);
    textFont(createFont("fonts/acmesa.ttf", 8));
    setViewBox(0,0,screenWidth,screenHeight);
    mario = new Mario();    
  }
  
  void updateMario(Player mario_new) {
    updatePlayer(mario, mario_new);
    mario = mario_new;
  }

  /**
   * Now then, the draw loop: render mario in
   * glorious canvas definition.
   */
  void draw() {
    if (!finished) {
      super.draw();
      viewbox.track(this, mario);
      // just to be sure
      if(mario.active!=null && mario.active.name!="dead" && (mario.x<-200 || mario.x>mario.layer.width+200 || mario.y<-200 || mario.y>mario.layer.height+200)) {
        reset();
        return;
      }
    }   

    // After mario's won, fade to black with
    // the win text in white. After 7.5 seconds,
    // (which is how long the sound plays), signal
    // that this level can be swapped out.
    else {
      endCount++;
      fill(255);
      textFont(createFont("fonts/acmesa.ttf", 62));
      text(wintext, (512-textWidth(wintext))/2, 192);
      fill(0, 8);
      rect(-1, -1, width+2, height+2);
      if (endCount>7.5*frameRate) {
        SoundManager.stop(this);
        reset();
      }
    }
  }
}
