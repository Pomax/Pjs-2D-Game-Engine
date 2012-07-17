/**
 * Pjs object monitor
 */
var ProcessingInspector = {
  monitor: function(object, attr, callback) {
    var prev = object;
    while(object && object[attr]) { prev = object; object = object.baseClass; }
    object = prev;

    // kill off property
    var _cached = object[attr];
    delete(object[attr]);

    // Lift up this property using a closure
    props = (function(attr, v) {
       var lifted_value = v;
       props = {
         get : function() { return lifted_value; },
         set : function(v) {
                 if (v!=lifted_value) {
                   lifted_value = v;
                   callback(object, attr, v);
                 }
               },
         configurable : true,
         enumerable : true };
       return props;
     }(attr, _cached));

    Object.defineProperty(object, attr, props);
  }
};
