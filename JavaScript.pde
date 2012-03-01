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
  abstract void setCoordinate(float x, float y);
  abstract void setPaths(ArrayList<ShapePrimitive> segments);
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
  // how do we prevent IE9 from not-running-without-debugger-open?
  if(js.console != null) {
    js.console.log("JavaScript bound to sketch");
  }
}
