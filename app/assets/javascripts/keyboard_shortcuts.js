(function() {
  function focusFilter() {
    $('.filter').select();
    return false;
  }

  function ready() {
    Mousetrap.bind('/', focusFilter);
  }

  $(document).on('turbolinks:load', ready);
})();
