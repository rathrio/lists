(function() {
  function focusFilter() {
    $('.filter').select();
    return false;
  }

  function visit(url) {
    window.location.replace(url);
  }

  function gotoHome() {
    visit('/');
  }

  function gotoArchived() {
    visit('/items?archived=true');
  }

  function ready() {
    Mousetrap.bind('/', focusFilter);
    Mousetrap.bind('g h', gotoHome);
    Mousetrap.bind('g a', gotoArchived);
  }

  $(document).on('turbolinks:load', ready);
})();
