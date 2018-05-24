// TODO port to plain js
var Modal = (function() {
  function closeAll() {
    $('.modal').removeClass('is-active');
  }

  function open(selector) {
    $(selector).addClass('is-active');
  }

  function toggle(selector) {
    $(selector).toggleClass('is-active');
  }

  function ready() {
    $('.modal-background').on('click', function(e) {
      e.preventDefault();
      closeAll();
    });
  }

  $(document).on('turbolinks:load', ready);

  return {
    closeAll: closeAll,
    toggle: toggle,
    open: open
  };
})();
