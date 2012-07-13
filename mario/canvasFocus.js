document.addEventListener("DOMContentLoaded",function(){
  // while focussed, play sketch
  $("canvas").focus(function(){
    //window.console.log('focus on '+this.id);
    var sketch = Processing.getInstanceById(this.id);
    if (sketch) {
      if(sketch.loop) sketch.loop();
      if(sketch.unmute) sketch.unmute();
    }
  });
  
  // when focus is lost, pause sketch
  $("canvas").blur(function(){
    //window.console.log('focus lost by '+this.id);
    var sketch = Processing.getInstanceById(this.id);
    if (sketch) {
      if(sketch.noLoop) sketch.noLoop();
      if(sketch.mute) sketch.mute();
    }
  });
});