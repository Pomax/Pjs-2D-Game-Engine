/**
 * Things can listen to boundary collisions for a boundary
 */
interface BoundaryCollisionListener {
  void collisionOccured(Boundary boundary, Actor actor, float[] intersectionInformation);
}