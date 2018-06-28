import * as Mousetrap from 'mousetrap';
import Modal from './modal';
import Rails from './rails';

function focusFilter() {
  window.scrollTo(0, 0);

  const input = document.getElementById('omni-bar');
  input!.focus();

  // Comment in for selecting the input
  // input.select()

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

function toggleItemStatus() {
  const elements = document.querySelectorAll(':hover');

  if (elements.length === 0) {
    return true;
  }

  const itemBox = Array.from(elements).find((node) =>
    node.className.includes('item-box')
  );

  const toggle = itemBox!.getElementsByClassName(
    'item-status-toggle'
  )[0] as HTMLElement;

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

[1, 2, 3, 4, 5, 6, 7, 8, 9].forEach((n) => {
  Mousetrap.bind(n.toString(), gotoList);
});
