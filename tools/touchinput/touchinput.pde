/** touch screen controls **/

// to keep Processing happy, proxy classes
abstract class TouchEventdata { int offsetX, offsetY; }
abstract class TouchEvent { TouchEventdata[] touches; }
interface JavaScript { void pressKey(int keyCode); void releaseKey(int keyCode); }
void bindJavaScript(JavaScript js) { javascript = js; }

// soft-key
class Button{
  float x,y,w,h;
  color plain = color(255,255,200);
  color touched = color(240,240,255);
  color current = plain;
  String label;

  Button(String label, float x, float y, float w, float h) {
    this.label=label; this.x=x; this.y=y; this.w=w; this.h=h; }

  boolean over(float mx, float my) {
    return x<=mx && mx<=x+w && y<=my && my<=y+h; }
  
  void touch() {
    current = touched;
    if(javascript!=null) {
      if(label=="Z") { javascript.pressKey(90); }
      else if(label=="X") { javascript.pressKey(88); }
      else if(label=="↑") { javascript.pressKey(38); }
      else if(label=="←") { javascript.pressKey(37); }
      else if(label=="↓") { javascript.pressKey(40); }
      else if(label=="→") { javascript.pressKey(39); }}  }

  void release() {
    current = plain;
    if(javascript!=null) {
      if(label=="Z") { javascript.releaseKey(90); }
      else if(label=="X") { javascript.releaseKey(88); }
      else if(label=="↑") { javascript.releaseKey(38); }
      else if(label=="←") { javascript.releaseKey(37); }
      else if(label=="↓") { javascript.releaseKey(40); }
      else if(label=="→") { javascript.releaseKey(39); }}  }
  
  void draw() {
    fill(current);
    rect(x,y,w,h);
    fill(0);
    text(label, x+w/2, y+h/2); }
}

// =========

ArrayList<Button> buttons = new ArrayList<Button>();
JavaScript javascript;

void setup()
{
  size(300,100);
  noLoop();
  // jump and shoot!
  buttons.add(new Button("X",250,0,50,50));
  buttons.add(new Button("Z",175,25,50,50));
  // cursor keys
  buttons.add(new Button("↑", 50,0,50,50));
  buttons.add(new Button("←",  0, 50,50,50));
  buttons.add(new Button("↓", 50, 50,50,50));
  buttons.add(new Button("→",100, 50,50,50));
  // set up text properties
  textFont(createFont("Arial",24));
  textAlign(CENTER,CENTER);
  text("",0,0);
}

// draw our virtual keyboard
void draw() {
  background(255);
  noFill();
  stroke(230,230,255);
  rect(0,0,width-1,height-1);
  for(Button b: buttons) { b.draw(); }
}

// touch a button
private void touch(int mx, int my) {
  for(Button b: buttons) { 
    if(b.over(mx,my)) {
      b.touch(); }}}

// release a button
private void release(int mx, int my) {
  for(Button b: buttons) { 
    if(b.over(mx,my)) {
      b.release(); }}}

/**
 * Press a virtual keyboard button!
 */
void touchStart(TouchEvent t) { 
  for (int i=0; i<t.touches.length; i++) {
    touch(t.touches[i].offsetX, t.touches[i].offsetY); }
  redraw(); }

/**
 * Release a virtual keyboard button.
 */
void touchEnd(TouchEvent t) {
  for (int i=0; i<t.touches.length; i++) {
    release(t.touches[i].offsetX, t.touches[i].offsetY); }
  redraw(); }

/**
 * Also release a virtual keyboard button.
 */
void touchCancel(TouchEvent t) {
  for (int i=0; i<t.touches.length; i++) {
    release(t.touches[i].offsetX, t.touches[i].offsetY); }
  redraw(); }