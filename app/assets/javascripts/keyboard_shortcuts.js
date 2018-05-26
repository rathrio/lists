(function() {
  function focusFilter() {
    window.scrollTo(0, 0);

    var input = document.getElementsByClassName('filter')[0];
    input.focus()
    input.select()

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
    var link = document.querySelector(selector);

    if (link.length === 0) {
      return;
    }

    visit(link.href);
  }

  function toggleShortcutsModal() {
    Modal.toggle("shortcuts-modal");
  }

  function closeModals() {
    Modal.closeAll();
  }

  function escapeActions() {
    closeModals();
  }

  document.addEventListener("turbolinks:load", function() {
    Mousetrap.bind('/', focusFilter);
    Mousetrap.bind('?', toggleShortcutsModal);
    Mousetrap.bind('esc', escapeActions);
    Mousetrap.bind('g h', gotoHome);
    Mousetrap.bind('g a', gotoArchived);
    Mousetrap.bind('g s', gotoSettings);

    [1, 2, 3, 4, 5, 6, 7, 8, 9].forEach(function(n) {
      Mousetrap.bind(n.toString(), gotoList);
    });
  });
})();
