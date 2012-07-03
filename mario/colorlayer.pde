/**
 * Plain color background layer
 */
class BackgroundColorLayer extends LevelLayer {
  BackgroundColorLayer(Level parent, float w, float h, color c) {
    super(parent, w, h);
    backgroundColor = c;
  }
}
