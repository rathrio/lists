import * as Mousetrap from 'mousetrap'

function focusFilter() {
  window.scrollTo(0, 0);

  const input = document.getElementById('omni-bar');
  input.focus()

  // Comment in for selecting the input
  // input.select()

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
  const key = n.key;
  const selector = '[data-shortcut="' + key + '"]';
  const link = document.querySelector(selector);

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

function toggleItemStatus() {
  const elements = document.querySelectorAll(':hover');

  if (elements.length == 0) {
    return;
  }

  var itemBox = Array.from(elements).find(node => (
    node.className.includes('item-box')
  ));

  var toggle = itemBox.getElementsByClassName('item-status-toggle')[0];
  if (toggle) {
    toggle.click();
  }

  return false;
}

Mousetrap.reset();

Mousetrap.bind('/', focusFilter);
Mousetrap.bind('?', toggleShortcutsModal);
Mousetrap.bind('esc', escapeActions);
Mousetrap.bind('g h', gotoHome);
Mousetrap.bind('g a', gotoArchived);
Mousetrap.bind('g s', gotoSettings);
Mousetrap.bind('space', toggleItemStatus);

[1, 2, 3, 4, 5, 6, 7, 8, 9].forEach(function (n) {
  Mousetrap.bind(n.toString(), gotoList);
});