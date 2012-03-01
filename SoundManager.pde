import ddf.minim.*;
import ddf.minim.signals.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
static class SoundManager {
  private static Minim minim;

  static void init(PApplet sketch) { 
    minim = new Minim(sketch); 
  }
  
  private static HashMap<Object,AudioPlayer> players = new HashMap<Object,AudioPlayer>();

  static void load(Object identifier, String filename) {
    players.put(identifier, minim.loadFile(filename));
  }

  static void play(Object identifier) {
    AudioPlayer ap = players.get(identifier);
    ap.play();
  }

  static void pause(Object identifier) {
    AudioPlayer ap = players.get(identifier);
    ap.pause();
  }
  
  static void stop(Object identifier) {
    AudioPlayer ap = players.get(identifier);
    ap.pause();
    ap.rewind();
  }
}
