/**
 * Minim-emulation code by Daniel Hodgin
 */

// wrap the P5 Minim sound library classes
function Minim() {
  this.loadFile = function (str) {
    return new AudioPlayer(str);
  }
}

// Browser Audio API
function AudioPlayer(str) {
  var loaded = false;
  var looping = false;

  if (!!document.createElement('audio').canPlayType) {
    var audio = document.createElement('audio');
    audio.addEventListener('ended', function () {
      if (looping) {
        this.currentTime = 0;
        this.play();
      }
    }, false);
    audio.preload = 'auto';
    audio.autobuffer = true;
    if (canPlayOgg()) {
      audio.src = str.split(".")[0] + ".ogg";
    } else if (canPlayMp3()) {
      audio.src = str;
    }
    loaded = true;
  }
  this.play = function () {
    if (!loaded || audio.readyState==0) {
      var local = this;
      setTimeout(function() { local.play(); }, 50);
      return;
    }
    audio.play();
  };
  this.loop = function () {
    if (!loaded || audio.readyState==0) {
      var local = this;
      setTimeout(function() { local.loop(); }, 50);
      return;
    }
    //audio.loop = 'loop';
    looping = true;
    audio.play();
  };
  this.pause = function () {
    if (!loaded) {
      return;
    }
    audio.pause();
  };
  this.rewind = function () {
    if (!loaded || audio.readyState==0) {
      return;
    }
    // rewind the sound to start
    audio.currentTime = 0;
  };
}

function canPlayOgg() {
  var a = document.createElement('audio');
  return !!(a.canPlayType && a.canPlayType('audio/ogg; codecs="vorbis"').replace(/no/, ''));
}

function canPlayMp3() {
  var a = document.createElement('audio');
  return !!(a.canPlayType && a.canPlayType('audio/mpeg;').replace(/no/, ''));
}
