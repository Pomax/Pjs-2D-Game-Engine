/**
 * The SoundManager is a static class that is responsible
 * for handling audio loading and playing. Any audio
 * instructions are delegated to this class. In Processing
 * this uses the Minim library, and in Processing.js it
 * uses the HTML5 <audio> element, wrapped by some clever
 * JavaScript written by Daniel Hodgin that emulates an
 * AudioPlayer object so that the code looks the same.
 */
import ddf.minim.*;
import ddf.minim.signals.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
static class SoundManager {
  private static Minim minim;
  static void init(PApplet sketch) { 
    minim = new Minim(sketch); 
  }
  
  private static HashMap<Object,AudioPlayer> owners = new HashMap<Object,AudioPlayer>();
  private static HashMap<String,AudioPlayer> audioplayers = new HashMap<String,AudioPlayer>();

  static void load(Object identifier, String filename) {
    // We recycle audio players to keep the
    // cpu and memory footprint low.
    AudioPlayer player = audioplayers.get(filename);
    if(player==null) {
      player = minim.loadFile(filename);
      audioplayers.put(filename, player); }
    owners.put(identifier, player);
  }

  static void play(Object identifier) {
    rewind(identifier);
    AudioPlayer ap = owners.get(identifier);
    if(ap==null) {
      println("ERROR: Error in SoundManager, no AudioPlayer exists for "+identifier.toString());
      return;
    }
    ap.play();
  }

  static void pause(Object identifier) {
    AudioPlayer ap = owners.get(identifier);
    if(ap==null) {
      println("ERROR: Error in SoundManager, no AudioPlayer exists for "+identifier.toString());
      return;
    }
    ap.pause();
  }

  static void rewind(Object identifier) {
    AudioPlayer ap = owners.get(identifier);
    if(ap==null) {
      println("ERROR: Error in SoundManager, no AudioPlayer exists for "+identifier.toString());
      return;
    }
    ap.rewind();
  }

  static void stop(Object identifier) {
    AudioPlayer ap = owners.get(identifier);
    if(ap==null) {
      println("ERROR: Error in SoundManager, no AudioPlayer exists for "+identifier.toString());
      return;
    }
    ap.pause();
    ap.rewind();
  }
}
