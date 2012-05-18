/***************************************
 *                                     *
 *        LEVEL IMPLEMENTATION         *
 *                                     *
 ***************************************/

class MarioLevel extends Level {
  Player mario;
  String wintext = "Goal!";
  int endCount = 0;

  MarioLevel(float w, float h) { 
    super(w, h);
  }

  void updateMario(Player newMario) {
    updatePlayer(mario, newMario);
    mario = newMario;
  }

  /**
   * Now then, the draw loop: render mario in
   * glorious canvas definition.
   */
  void draw() {
    if (!finished) {
      super.draw();
      mario.constrainPosition();
      viewbox.track(this, mario);
      if (javascript!=null) {
        javascript.setCoordinate(mario.x, mario.y);
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
      rect(0, 0, width, height);
      if (endCount>7.5*frameRate) {
        SoundManager.stop(this);
        setSwappable();
      }
    }
  }
}