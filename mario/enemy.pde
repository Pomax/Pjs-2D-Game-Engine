/**
 * This lets us define enemies as being part of
 * some universal class of things, as opposed to
 * non enemy NPCs (like yoshis or toadstools)
 */

abstract class MarioEnemy extends Interactor {
  MarioEnemy(String name) { super(name); } 
  MarioEnemy(String name, float x, float y) { super(name, x, y); } 
}

abstract class BoundedMarioEnemy extends BoundedInteractor {
  BoundedMarioEnemy(String name) { super(name); } 
  BoundedMarioEnemy(String name, float x, float y) { super(name, x, y); } 
}


/***
 * Enemies: koopa, banzai bill, muncher, bonus target
 ***/
