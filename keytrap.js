/**
 * First, a warning: "Don't be a jackass."
 *
 * This script lets your intercept keys that are normally
 * handled by the browser at the document level. Cursor
 * keys, tab, backspace, etc. all have well defined intended
 * behaviours, and intercepting them means those never get
 * triggered. So don't be a jackass, and don't intercept
 * keys just because you want to prevent people from using them.
 *
 * In fact, let's make that the license agreement:
 *
 * You are permitted to use this package however you see
 * fit, except when that use interferes with the user's
 * expectations of browser interaction.
 *
 * There, now we're both covered.
 *
 * Legitimate uses include things like browser games,
 * where (as long as the game has focus) you definitely
 * don't want backspace or tab to go to the previous
 * page, or move focus to the next focussable element.
 * Users except the keys to stay trapped inside the game.
 *
 * Or say you're using an autosuggestion box tied to an
 * input field, and users can cursor up and down through
 * the suggestion box. Typing a backspace should then clearly
 * not go the previous page, but put focus back on the input
 * field and remove the last character in the .value string.
 *
 * There are plenty of legitimate uses, so go make the
 * web a little better by preventing default browser
 * behaviour when users do not expect that behaviour to
 * be triggered.
 *
 * (c) Mike "Pomax" Kamermans, 2011
 */
var KeyTrap = (function () { return {

  /**
   * Trap the specified keys, preventing them
   * from being acted on by the browser at the
   * document level.
   */
  trap: function (element, keys, callback) {
    var onfocus,
      onblur,
      trapkeys = function (element, keys, callback) {
        element.originalDocumentKeyDown = document.onkeydown;
        element.originalDocumentKeyPress = document.onkeypress;

        var trapfunction = (function (element, trapkeys, handle) {
          return function (e) {
            var keynum, allowed, event = window.event || e;
            if (window.event) {
              keynum = window.event.keyCode;
            } else if (event.which) {
              keynum = event.which;
            }
            allowed = (trapkeys.indexOf(keynum) === -1);
            // because you probably want to do something
            // else with these keys, you can pass a callback
            // function for handling trapped keys.
            if (handle && !allowed) {
              handle(element, keynum);
            }
            return allowed;
          };
        }(element, keys, callback));

        document.onkeydown = trapfunction;
        document.onkeypress = trapfunction;
      };

    // if this element is not focussable, make it focussable
    if (!element.tabindex) {
      element.setAttribute("tabindex","0");
    }

    // when focus is on this element, trap the indicated keys
    onfocus = function () {
      trapkeys(element, keys, callback);
    };
    element.addEventListener("focus", onfocus, false);

    // when focus is lost, remove trapping on document.
    onblur = function () {
      document.onkeydown = element.originalDocumentKeyDown;
      document.onkeypress = element.originalDocumentKeyPress;
    };
    element.addEventListener("blur", onblur, false);
  }
}; }());

/**
 * is jQuery loaded? If so, we add a .trap() function to it
 */
if (typeof jQuery !== 'undefined') {
  jQuery.fn.trap = function (keys, callback) {
    return this.each(function () {
      KeyTrap.trap(this, keys, callback);
    });
  };
}
