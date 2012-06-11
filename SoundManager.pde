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
  private static boolean muted = true;
  private static Minim minim;
  private static HashMap<Object,AudioPlayer> owners;
  private static HashMap<String,AudioPlayer> audioplayers;
  public static PImage mute_overlay;
  public static PImage unmute_overlay;
  public static PImage volume_overlay;

  static void init(PApplet sketch) { 
    owners = new HashMap<Object,AudioPlayer>();
    audioplayers = new HashMap<String,AudioPlayer>();
    mute_overlay = sketch.loadImage("mute.gif");
    unmute_overlay = sketch.loadImage("unmute.gif");
    volume_overlay = (muted ? unmute_overlay : mute_overlay);
    minim = new Minim(sketch); 
    reset();
  }

  static void reset() {
    owners = new HashMap<Object,AudioPlayer>();
  }

  static void load(Object identifier, String filename) {
    // We recycle audio players to keep the
    // cpu and memory footprint low.
    AudioPlayer player = audioplayers.get(filename);
    if(player==null) {
      player = minim.loadFile(filename);
      if(muted) player.mute();
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

  static void loop(Object identifier) {
    rewind(identifier);
    AudioPlayer ap = owners.get(identifier);
    if(ap==null) {
      println("ERROR: Error in SoundManager, no AudioPlayer exists for "+identifier.toString());
      return;
    }
    ap.loop();
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
  
  static void mute(boolean _muted) {
    muted = _muted;
    for(AudioPlayer ap: audioplayers.values()) {
      if(muted) { ap.mute(); }
      else { ap.unmute(); }
    }
    volume_overlay = (muted ? unmute_overlay : mute_overlay);
  }
}
