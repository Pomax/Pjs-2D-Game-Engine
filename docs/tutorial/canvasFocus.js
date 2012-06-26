document.addEventListener("DOMContentLoaded",function(){
  // while focussed, play sketch
  $("canvas").focus(function(){
    window.console.log('focus on '+this.id);
    Processing.getInstanceById(this.id).loop();
    Processing.getInstanceById(this.id).unmute();
  });
  
  // when focus is lost, pause sketch
  $("canvas").blur(function(){
    window.console.log('focus lost by '+this.id);
    Processing.getInstanceById(this.id).noLoop();
    Processing.getInstanceById(this.id).mute();
  });
});