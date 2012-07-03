/**
 * JavaScript interface, to enable console.log
 */
interface JSConsole { void log(String msg); }

/**
 * Abstract JavaScript class, containing
 * a console object (with a log() method)
 * and access to window.setPaths().
 */
abstract class JavaScript {
  JSConsole console;
  abstract void loadInEditor(Positionable thing);
  abstract boolean shouldMonitor();
  abstract void updatedPositionable(Positionable thing);
  abstract void reset();
}

/**
 * Local reference to the javascript environment
 */
JavaScript javascript;

/**
 * Binding function used by JavaScript to bind
 * the JS environment to the sketch.
 */
void bindJavaScript(JavaScript js) {
  javascript = js;
}

