(function() {
  function focusFilter() {
    window.scrollTo(0, 0);
    $('.filter').select();
    return false;
  }

  function visit(url) {
    Turbolinks.visit(url);
  }

  function gotoHome() {
    visit('/');
  }

  function gotoArchived() {
    visit('/items?archived=true');
  }

  function gotoList(n) {
    var key = n.key;
    var selector = '[data-shortcut="' + key + '"]';
    var link = $(selector);

    if (link.length === 0) {
      return;
    }

    var url = link.attr("href");
    visit(url);
  }

  function ready() {
    Mousetrap.bind('/', focusFilter);
    Mousetrap.bind('g h', gotoHome);
    Mousetrap.bind('g a', gotoArchived);

    [1, 2, 3, 4, 5, 6, 7, 8, 9].forEach(function(n) {
      Mousetrap.bind(n.toString(), gotoList);
    });
  }

  $(document).on('turbolinks:load', ready);
})();
