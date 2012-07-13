final int screenWidth = 512;
final int screenHeight = 432;

void initialize() {
  addScreen("level", new MarioLevel(width, height));
  draw();
}

class MarioLevel extends Level {
  MarioLevel(float levelWidth, float levelHeight) {
    super(levelWidth, levelHeight);
    addLevelLayer("layer", new MarioLayer(this));
  }
}
class MarioLayer extends LevelLayer {
  MarioLayer(Level owner) {
    super(owner);
    setBackgroundColor(color(0, 100, 190));
    addBoundary(new Boundary(0,height-48,width,height-48));
    showBoundaries = true;
  }
}