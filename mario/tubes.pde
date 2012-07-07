/**
 * Tube trigger - teleports between locations
 */
class TeleportTrigger extends Trigger {
  float popup_speed = -40;
  float tx, ty;
  Boundary lid;
  TeleportTrigger(float tx, float ty) {
    super("teleporter");
    this.tx = tx;
    this.ty = ty;
  }
  void setLid(Boundary lid) { 
    this.lid = lid;
  }
  void run(LevelLayer layer, Actor actor, float[] intersection) {
    // spit mario back out
    actor.stop();
    actor.setPosition(tx, ty);
    actor.setImpulse(0, popup_speed);
    if (lid != null) {
      lid.enable();
    }
  }
}

/**
 * Tube trigger - teleports between layers
 */
class LayerTeleportTrigger extends TeleportTrigger {
  String layerName;
  LayerTeleportTrigger(String _layer, float tx, float ty) {
    super(tx,ty);
    layerName = _layer;
  }
  void run(LevelLayer layer, Actor actor, float[] intersection) {
    super.run(layer, actor, intersection);
    if(actor instanceof Player) {
      Player p = (Player) actor;      
      LevelLayer current = p.layer;
      current.removePlayer(p);
      LevelLayer next = current.parent.getLevelLayer(layerName);
      next.addPlayer(p);
    }
  }
}

/**
 * Tube trigger - teleports between levels
 */
class LevelTeleportTrigger extends TeleportTrigger {
  String levelName;
  LevelTeleportTrigger(String _level, float x, float y, float w, float h, float tx, float ty) {
    super(tx,ty);
    levelName = _level;
  }
  void run(LevelLayer layer, Actor actor, float[] intersection) {
    super.run(layer, actor, intersection);
    if(actor instanceof Player) {
      Player p = (Player) actor;
      setActiveScreen(levelName);
      MarioLevel a = (MarioLevel) activeScreen;
      a.updateMario(p);
    }
  }
}

/**
 * Removable boundary for pipes, acts as lid
 */
class PipeBoundary extends Boundary {
  // wrapper constructor
  PipeBoundary(float x1, float y1, float x2, float y2) {
    super(x1, y1, x2, y2);
    SoundManager.load(this, "audio/Pipe.mp3");
  }
  // used to effect "teleporting" in combination with the teleport trigger
  void trigger(Player p) {
    p.setPosition((x+xw)/2, y);
    disable();
    SoundManager.play(this);
  }
}

