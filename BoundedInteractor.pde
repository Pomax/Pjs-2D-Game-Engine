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
  void addBoundary(Boundary boundary) { 
    // TODO: check where else we need to tie values together
    boundary.setImpulseCoefficients(ixF,iyF);
    boundaries.add(boundary); 
  }

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
    for(int b=boundaries.size()-1; b>=0; b--) {
      Boundary boundary = boundaries.get(b);
      boundary.disable();
      boundary.detachAll();
    }
  }
  
  /**
   * We must make sure to remove all
   * boundaries when we are removed.
   */
  void removeActor() {
    disableBoundaries();
    boundaries = new ArrayList<Boundary>();
    super.removeActor();
  }
  
  // draw boundaries
  void drawBoundaries(float x, float y, float w, float h) {
    for(Boundary b: boundaries) {
      b.draw(x,y,w,h);
    }
  }
  
  /**
   * Is something attached to one of our boundaries?
   */
  boolean havePassenger() {
    for(Boundary b: boundaries) {
      if(b.attached.size()>0) {
        return true;
      }
    }
    // no passengers
    return false;
  }

  // when we update our coordinates, also
  // update our associated boundaries.
  void update() {
    super.update();

    // how much did we actually move?
    float dx = x-prevx;
    float dy = y-prevy;
    // if it's not 0, move the boundaries
    if(dx!=0 && dy!=0) {
      for(Boundary b: boundaries) {
        // FIXME: somehow this goes wrong when the
        // interactor is contrained by another
        // boundary, where the actor moves, but the
        // associated boundary for some reason doesn't.
        b.moveBy(dx,dy);
      }
    }
  }
}
