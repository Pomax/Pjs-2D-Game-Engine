// *****************
//
  var ActorVariables = function(actor) { 
    this.thing = actor;
    this.update(actor);
  }

  ActorVariables.prototype = {
    // general update
    update: function(actor) {
      // position
      this.x = actor.x;
      this.y = actor.y;
      // offsets
      this.ox = actor.ox;
      this.oy = actor.oy;
      // impulse
      this.ix = actor.ix;
      this.iy = actor.iy;
      // impulse coefficients
      this.ixF = actor.ixF;
      this.iyF = actor.iyF;
      // forces
      this.fx = actor.fx;
      this.fy = actor.fy;
      // acceleration
      this.ixA = actor.ixA;
      this.iyA = actor.iyA;
      
      // FIXME: temporary hack - replace full info panel
      if(this.html !== undefined) {
        var oldHTML = this.toHTML();
        var parent = oldHTML.parentNode;
        this.html = undefined;
        var newHTML = this.toHTML();
        parent.replaceChild(newHTML,oldHTML);
      }
    },

    // position
    updatePosition: function(actor) {
      actor.thing.setPosition(actor.x, actor.y);
    },

    // offsets
    updateOffset: function(actor) {
      actor.thing.ox = actor.ox;
      actor.thing.oy = actor.oy;
    },

    // impulse
    updateImpulse: function(actor) {
      actor.thing.setImpulse(actor.ix,actor.iy);  
    },

    // impuse coefficients
    updateImpulseCoefficients: function(actor) {
      actor.thing.setImpulseCoefficients(actor.ixF,actor.iyF);  
    },

    // forces
    updateForces: function(actor) {
      actor.thing.setForces(actor.fx,actor.fy);      
    },

    // acceleration
    updateAcceleration: function(actor) {
      actor.thing.setAcceleration(actor.ixA,actor.iyA);      
    },
    
    html: undefined,

    // form HTML element
    toHTML: function() {
      var local = this;
      if (this.html === undefined) {
        this.html = document.createElement("div");
        this.html.setAttribute("class","tab box");

        var name =  document.createElement("label");
        name.setAttribute("class","tab");
        name.innerHTML = local.thing.name;
        this.html.appendChild(name);

        this.addSpinner(this.html, "x", local, 'x', local.updatePosition);
        this.addSpinner(this.html, "y", local, 'y', local.updatePosition);
        this.addSpinner(this.html, "x impulse", local, 'ix', local.updateImpulse);
        this.addSpinner(this.html, "y impulse", local, 'iy', local.updateImpulse);
        this.addSpinner(this.html, "x impulse coefficients", local, 'ixF', local.updateImpulseCoefficients);
        this.addSpinner(this.html, "y impulse coefficients", local, 'iyF', local.updateImpulseCoefficients);
        this.addSpinner(this.html, "x force", local, 'fx', local.updateForces);
        this.addSpinner(this.html, "y force", local, 'fy', local.updateForces);
        this.addSpinner(this.html, "x acceleration", local, 'ixA', local.updateAcceleration);
        this.addSpinner(this.html, "y acceleration", local, 'iyA', local.updateAcceleration);

        this.html.onfocus = function(){};
        this.html.onblur = function(){};
      }

      return this.html;
    },
    
    // add a number spinner to an HTML element
    addSpinner: function(parent, text, object, propertyName, callback) {
      var div =  document.createElement("div");
     
      var label = document.createElement("label");
      label.innerHTML = text;
      div.appendChild(label);
      
      var spinner = document.createElement("input");
      spinner.type = "number";
      spinner.name = propertyName;
      spinner.min = -1000;
      spinner.max = 1000;
      spinner.step = 0.1;
      spinner.value = object[propertyName];
      spinner.oninput = function() { 
        object[propertyName] = parseFloat(spinner.value);
        callback(object);
      };
      div.appendChild(spinner);
      parent.appendChild(div);
    }
  };
  ActorVariables.prototype.constructor = ActorVariables;
//
// *****************


// quick and dirty dictionary - keys
var keys = [];

// quick and dirty dictionary - values
var actorvars = [];


/**
 * load some actor into the editor part of the page
 */
function loadInEditor(thing) {
  window.console.log(thing);
  keys.push(thing);
  actorvars[keys.length-1] = new ActorVariables(thing);
  thing.setMonitoredByJavaScript(true);
  document.getElementById("editor").appendChild(actorvars[keys.length-1].toHTML());
}


/**
 * tell a sketch whether JS should act as monitor
 */
function shouldMonitor() {
  return true;
}


/**
 * Update the position information for some Positionable
 */
function updatedPositionable(thing) {
  var idx = keys.indexOf(thing);
  var av = actorvars[idx];
  av.update(thing);
}


/**
 * reset the monitor
 */
function reset() {
  var editor = document.getElementById("editor");
  while(editor.children.length>0) {
    editor.removeChild(editor.children[0]);
  }
}