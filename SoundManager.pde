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
  static boolean reportErrors = false;
  private static PApplet sketch;
  private static Minim minim;

  private static HashMap<Object,AudioPlayer> owners;
  private static HashMap<String,AudioPlayer> audioplayers;

  private static boolean muted = true, draw_controls = false;
  private static float draw_x, draw_y;
  private static PImage mute_overlay, unmute_overlay, volume_overlay;
  
  public static void setDrawPosition(float x, float y) {
    draw_controls = true;
    draw_x = x - volume_overlay.width/2;
    draw_y = y - volume_overlay.height/2;
  }

  /**
   * Set up the sound manager
   */
  static void init(PApplet _sketch) { 
    sketch = _sketch;
    owners = new HashMap<Object,AudioPlayer>();
    mute_overlay = sketch.loadImage("mute.gif");
    unmute_overlay = sketch.loadImage("unmute.gif");
    volume_overlay = (muted ? unmute_overlay : mute_overlay);
    minim = new Minim(sketch); 
    reset();
  }

  /**
   * reset list of owners and audio players
   */
  static void reset() {
    owners = new HashMap<Object,AudioPlayer>();
    audioplayers = new HashMap<String,AudioPlayer>();
  }
  
  /**
   * if a draw position was specified,
   * draw the sound manager's control(s)
   */
  static void draw() {
    if(!draw_controls) return;
    sketch.pushMatrix();
    sketch.resetMatrix();
    sketch.image(volume_overlay, draw_x, draw_y);
    sketch.popMatrix();
  }
  
  /**
   * if a draw position was specified,
   * clicking on the draw region effects mute/unmute.
   */
  static void clicked(int mx, int my) {
    if(!draw_controls) return;
    if(draw_x<=mx && mx <=draw_x+volume_overlay.width && draw_y<=my && my <=draw_y+volume_overlay.height) {
      mute(!muted);
    }
  }

  /**
   * load an audio file, bound to a specific object.
   */
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

  /**
   * play an object-boud audio file. Note that
   * play() does NOT loop the audio. It will play
   * once, then stop.
   */
  static void play(Object identifier) {
    rewind(identifier);
    AudioPlayer ap = owners.get(identifier);
    if(ap==null) {
      if(reportErrors) println("ERROR: Error in SoundManager, no AudioPlayer exists for "+identifier.toString());
      return;
    }
    ap.play();
  }

  /**
   * play an object-boud audio file. Note that
   * loop() plays an audio file indefinitely,
   * rewinding and starting from the start of
   * the file until stopped.
   */
  static void loop(Object identifier) {
    rewind(identifier);
    AudioPlayer ap = owners.get(identifier);
    if(ap==null) {
      if(reportErrors) println("ERROR: Error in SoundManager, no AudioPlayer exists for "+identifier.toString());
      return;
    }
    ap.loop();
  }

  /**
   * Pause an audio file that is currently being played.
   */
  static void pause(Object identifier) {
    AudioPlayer ap = owners.get(identifier);
    if(ap==null) {
      if(reportErrors) println("ERROR: Error in SoundManager, no AudioPlayer exists for "+identifier.toString());
      return;
    }
    ap.pause();
  }

  /**
   * Explicitly set playback position to 0 for an audio file.
   */
  static void rewind(Object identifier) {
    AudioPlayer ap = owners.get(identifier);
    if(ap==null) {
      if(reportErrors) println("ERROR: Error in SoundManager, no AudioPlayer exists for "+identifier.toString());
      return;
    }
    ap.rewind();
  }

  /**
   * stop a currently playing or looping audio file.
   */
  static void stop(Object identifier) {
    AudioPlayer ap = owners.get(identifier);
    if(ap==null) {
      if(reportErrors) println("ERROR: Error in SoundManager, no AudioPlayer exists for "+identifier.toString());
      return;
    }
    ap.pause();
    ap.rewind();
  }
  
  /**
   * mute or unmute all audio. Note that this does
   * NOT pause any of the audio files, it simply
   * sets the volume to zero.
   */
  static void mute(boolean _muted) {
    muted = _muted;
    for(AudioPlayer ap: audioplayers.values()) {
      if(muted) { ap.mute(); }
      else { ap.unmute(); }
    }
    volume_overlay = (muted ? unmute_overlay : mute_overlay);
  }
}
