// always good to have lying around
var undef;

var preloads = [];
function preloadString() { return "/* @pjs preload = \"" + preloads.join(",\n") + "\"; */\n\n"; }


/**
 * Processing class constructor data structure
 */
var Constructor = function(functor, name) {
    // class and constructor name
  this.functor = functor;
  this.name = name;

  // constructor arguments
  this.args = [];
  this.setArguments = function(args) { 
    this.args = args;
  };
  // body code
  this.code = [];
  this.addCode = function(code) {
    this.code.push(code);
  };

  // generate constructor code    
  this.toString = function() {
    return this.functor + "(" + this.args.join(", ") + ") {\n" + 
            "  " + this.code.join("\n  ") + "\n" +
            "}";
  };
};


/**
 * Level code
 */
var Screen = function(w, h) {
  this.classname = undef;
  this.getClassName = function() { return this.classname; }
  
  this.ctr = undef;
  this.getConstructor = function() { return this.ctr; }

  // set the class/constructor name
  this.setName = function(name) { 
    this.classname = name.replace(/\s+/g,'');
    this.ctr = new Constructor(this.classname, name);   
    /** TEMP CODE **/
      this.ctr.addCode("super(w,h);");
      this.ctr.addCode("debug = true;");
      this.ctr.addCode("setViewBox(0,0,w,h);");
    /** TEMP CODE **/
  };

  // set the constructor's parameter list
  this.setConstructorArguments = function () { this.ctr.setArguments(Array.prototype.splice.call(arguments,0)); };

  // add code to the constructor body
  this.addConstructorCode = function(code) { this.ctr.addCode(code); };

  this.drawCode = new DrawCode();
  this.addDrawCode = function(code) { this.drawCode.addCode(code); }
  this.draw = function() { return "void draw() {\n"+ this.drawCode.toString() +"\n}"; }
  
  this.toString = function() {
    return "class " + this.getClassName() + " extends Level {\n\n" +
            this.getConstructor() + "\n\n" +
            this.draw() + "\n\n" + 
            "}";
  };
}



/**
  in order to generate preload information, we track preloads
  globally. These are then joined into a single @pjs directive.
**/



/**
 * Generic code-store object
 */
var CodeStore = function() {
  this.codeStore = [];
  this.addCode  = function(line) { this.codeStore.push(line); };
  this.joinCode = function(glue) { return this.codeStore.join("\n" + glue); };
  this.size = function() { return this.codeStore.length; }
  this.toString = function() { return "  " + this.joinCode("  "); };
};


/**
 * pickup handling is (currently) flat code passing
 */
var Pickups = function() { this.codeStore = []; };
Pickups.prototype = new CodeStore();
Pickups.prototype.constructor = Pickups;


/**
 * state finish handling is (currently) flat code passing
 */
var Finishes = function() { this.codeStore = []; };
Finishes.prototype = new CodeStore();
Finishes.prototype.constructor = Finishes;


/**
 * tracking code for actors that implement the P5 "Tracker" interface
 */
var Tracking = function() { this.codeStore = []; };
Tracking.prototype = new CodeStore();
Tracking.prototype.constructor = Tracking;


/**
 * input handling is (currently) flat code passing
 */
var Inputs = function() {
  this.codeStore = [];
  this.addInput = function(key, code) {
                     this.addCode("if(keyDown["+key+"]) { "+code+" }");
                   };
};
Inputs.prototype = new CodeStore();
Inputs.prototype.constructor = Inputs;


/**
 * Actor State representation in JavaScript, for defining the actor's states
 */
var States = function() {
  this.codeStore = [];
  this.states = [];
  this.addState = function(name, spritesheet, rows, columns) {
    var code = "  State "+name+" = new State(\""+name+"\", \""+spritesheet+"\"";
    if(rows!==undef && columns!==undef) { code += ", " + rows + ", " +columns; }
    code += ");";
    this.addCode(code);
    this.states.push("addState("+name+")");
  };
};
States.prototype = new CodeStore();
States.prototype.constructor = States;
// override for the toString function
States.prototype.toString = function() { return this.joinCode("  ") + "\n  " + this.states.join("\n  "); };

/**
 * Draw code
 */
var DrawCode = function() { this.codeStore = []; };
DrawCode.prototype = new CodeStore();
DrawCode.prototype.constructor = DrawCode;


// ========================================================================


/**
 * Actor representation in JavaScript, for dynamically generating the P5 code for an actor
 */
var Actor = function() {
  //** P5 class name **//
  var classname = undef; 
  this.getClassName = function() { return classname; }

  //** P5 constructor **//
  var ctr = undef;
  this.getConstructor = function() { return ctr.toString(); }

  // an actor has several states
  var states = new States();

  // the states-finished handling object
  var finishes = new Finishes();

  // the input handling object
  var input = new Inputs();

  // the pickups object
  var pickups = new Pickups();


/** The constructor **/

  // set the class/constructor name
  this.setName = function(name) { 
    classname = name.replace(/\s+/g,'');
    ctr = new Constructor(classname, name);   
    ctr.addCode("super(\"" + name + "\");");
    ctr.addCode("setupStates();");
  };

  // set the constructor's parameter list
  this.setConstructorArguments = function () { ctr.setArguments(Array.prototype.splice.call(arguments,0)); };

  // add code to the constructor body
  this.addConstructorCode = function(code) { ctr.addCode(code); };


/** states for this actor **/
  
  // this function generates the setupStates Processing code
  this.setupStates = function() { return "void setupStates() {\n" + states.toString() + "\n}"; };

  // add a state to this actor, making sure to add the image
  // used for the state to the list of image preloads
  this.addState = function(name, spritesheet, rows, columns) { 
    preloads.push(spritesheet);
    states.addState(name, spritesheet, rows, columns);
  };

  // add specific code to the setupStates function body
  this.addStateCode = function(code) { states.addCode(code); };


/** state finish handling **/
    
  // generate the Processing handleStateFinished function
  this.handleStateFinished = function() {
    if(finishes.size()>0) {
      return "void handleStateFinished(State which) {\n" + finishes.toString() + "\n}";
    } return false; 
  };

/** input handling **/

  // generate the Processing handleInput function
  this.handleInput = function() {
    if(input.size()>0) { 
      return "void handleInput() {\n" + input.toString() + "\n}";
    } return false; 
  };

  // add input hanlding for a specific key
  this.addInputHandling = function(key, code) { input.addInput(key, code); };


/** pickup handling **/

  // generate the Processing pickedUp function
  this.pickedUp = function() {
    if(pickups.size()>0) { 
      return "void pickedUp(Pickup pickup) {\n" + pickups.toString() + "\n}";
    } return false; 
  };

  /**
   * This function generates the Processing code for our Actor
   */
  this.toString = function() {
    return "class " + this.getClassName() + " extends Actor {\n\n" +
            this.getConstructor() + "\n\n" +
            this.setupStates() + "\n\n" +
            (this.handleInput() !== false ? this.handleInput() + "\n\n" : "") +
            (this.handleStateFinished() !== false ? this.handleStateFinished() + "\n\n" : "") + 
            (this.pickedUp() !== false ? this.pickedUp() + "\n\n" : "") + 
            "}";
  };
};


// ========================================================================


/**
 * Code for a tracking interactor
 */
var Tracker = function() {
  var tracker = new Tracking();
  this.track = function() { return "void track(Actor actor) {\n" + tracker.toString() + "\n}";  };
  this.addTracking = function(condition, code) { tracker.addCode("if("+condition+") {\n"+code+"\n  }"); };
};
Tracker.prototype = new Actor();
Tracker.prototype.constructor = Tracker;

/**
 * In order to add the tracking method, we override Actor.toString()
 */
Tracker.prototype.toString = function() {
  return "class " + this.getClassName() + " extends Interactor implements Tracker {\n\n" +
          this.getConstructor() + "\n\n" +
          this.setupStates() + "\n\n" +
          (this.handleStateFinished() !== false ? this.handleStateFinished() + "\n\n" : "") + 
          this.track() + "\n\n" +
          "}";
};


