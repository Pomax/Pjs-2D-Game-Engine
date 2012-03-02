/**
 * A bounded interactor is a normal Interacto with
 * one or more boundaries associated with it. This
 * can be something like a Mario coin block, or a
 * walking platform.
 */
abstract class BoundedInteractor extends Interactor {
  // the list of associated boundaries
  ArrayList<Boundary> boundaries = new ArrayList<Boundary>();

  // are the boundaries active?
  boolean bounding = true;
  
  // simple constructor
  BoundedInteractor(String name) { super(name); }

  // full constructor
  BoundedInteractor(String name, float dampening_x, float dampening_y) {
    super(name, dampening_x, dampening_y); }

  // add a boundary
  void addBoundary(Boundary boundary) { boundaries.add(boundary); }

  // FIXME: make this make sense, because setting 'next'
  //        should only work on open-bounded interactors.
  void setNext(BoundedInteractor next) {
    if(boundaries.size()==1) {
      boundaries.get(0).setNext(next.boundaries.get(0));
    }
  }

  // FIXME: make this make sense, because setting 'previous'
  //        should only work on open-bounded interactors.
  void setPrevious(BoundedInteractor prev) {
    if(boundaries.size()==1) {
      boundaries.get(0).setPrevious(prev.boundaries.get(0));
    }
  }

  // enable all boundaries
  void enableBoundaries() {
    bounding = true;
    for(Boundary b: boundaries) {
      b.enable();
    }
  }

  // disable all boundaries
  void disableBoundaries() {
    bounding = false;
    for(Boundary b: boundaries) {
      b.disable();
      b.detachAll();
    }
  }
  
  // draw boundaries
  void drawBoundaries(float x, float y, float w, float h) {
    for(Boundary b: boundaries) {
      b.draw(x,y,w,h);
    }
  }
}
