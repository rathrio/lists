import * as Mousetrap from 'mousetrap';
import Modal from './modal';
import Rails from './rails';

function focusFilter() {
  window.scrollTo(0, 0);

  const input = document.getElementById('omni-bar') as HTMLInputElement;
  input.focus();
  input.select();

  return false;
}

function visit(url: string) {
  Rails.visit(url);
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

function gotoList(n: KeyboardEvent) {
  const key = n.key;
  const selector = `[data-shortcut="${key}"]`;
  const link = document.querySelector(selector) as HTMLAnchorElement;

  if (!link) {
    return;
  }

  visit(link.href);
}

function toggleShortcutsModal() {
  Modal.toggle('shortcuts-modal');
}

function closeModals() {
  Modal.closeAll();
}

function escapeActions() {
  closeModals();
}

Mousetrap.reset();

Mousetrap.bind('/', focusFilter);
Mousetrap.bind('?', toggleShortcutsModal);
Mousetrap.bind('esc', escapeActions);
Mousetrap.bind('g h', gotoHome);
Mousetrap.bind('g a', gotoArchived);
Mousetrap.bind('g s', gotoSettings);

[1, 2, 3, 4, 5, 6, 7, 8, 9].forEach((n) => {
  Mousetrap.bind(n.toString(), gotoList);
});
