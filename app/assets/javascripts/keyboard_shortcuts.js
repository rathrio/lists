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

  function gotoSettings() {
    visit('/lists');
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

  function toggleShortcutsModal() {
    Modal.toggle(".shortcuts-modal");
  }

  function closeModals() {
    Modal.closeAll();
  }

  function abortScraper() {
    Scraper.abort();
  }

  function escapeActions() {
    closeModals();
  }

  function escape() {
    visit('/sign_out');
  }

  function ready() {
    Mousetrap.bind('/', focusFilter);
    Mousetrap.bind('?', toggleShortcutsModal);
    Mousetrap.bind('esc', escapeActions);
    Mousetrap.bind('g h', gotoHome);
    Mousetrap.bind('g a', gotoArchived);
    Mousetrap.bind('g s', gotoSettings);

    [1, 2, 3, 4, 5, 6, 7, 8, 9].forEach(function(n) {
      Mousetrap.bind(n.toString(), gotoList);
    });
  }

  $(document).on('turbolinks:load', ready);
})();
