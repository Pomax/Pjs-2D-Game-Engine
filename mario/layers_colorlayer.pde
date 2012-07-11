/**
 * Plain color background layer
 */
class BackgroundColorLayer extends LevelLayer {
  BackgroundColorLayer(Level parent, color c) {
    super(parent, parent.width, parent.height);
    backgroundColor = c;
  }
}
