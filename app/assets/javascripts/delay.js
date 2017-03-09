// http://stackoverflow.com/a/1909508/1314848
//
// @param {function} callback - callback function invoked after milliseconds
// @param {number} milliseconds - delay in milliseconds before invoking callback
var delay = (function() {
  var timer = 0;
  return function(callback, milliseconds) {
    clearTimeout(timer);
    timer = setTimeout(callback, milliseconds);
  };
})();
