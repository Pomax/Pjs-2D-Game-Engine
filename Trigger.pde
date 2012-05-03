/**
 * Triggers can make things happen in levels.
 * They define a region through which a player
 * Actor has to pass for it to trigger.
 */
abstract class Trigger extends Positionable {
  boolean remove = false, disabled = false;
  String triggername="";
  
  Trigger(String name, float x, float y, float w, float h) {
    super(x,y,w,h);
    triggername = name;
  }

  boolean drawableFor(float x, float y, float w, float h) {
    return x<=this.x+width && this.x<=x+w && y<=this.y+height && this.y<=y+h;
  }
  
  void drawObject() {
    fill(255,127,0,150);
    rect(-width/2,height/2,width,height);
    fill(0);
    textSize(12);
    float tw = textWidth(triggername);
    text(triggername,-5-tw,height);
  }
  
  void enable() { disabled = false; }
  void disable() { disabled = true; }
  void removeTrigger() { remove = true; }

  abstract void run(LevelLayer level, Actor actor, float[] intersection);
}
