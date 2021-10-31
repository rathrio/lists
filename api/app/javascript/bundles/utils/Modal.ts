/**
 * Actions for non-react controlled modals, e.g. modals rendered with Rails.
 * Note that these modals set the "non-react-modal" and
 * "non-react-modal-background" class.
 */
const Modal = (() => {
  function closeAll() {
    const modals = document.getElementsByClassName('non-react-modal');
    for (let i = 0; i < modals.length; i += 1) {
      const modal = modals[i];
      modal.classList.remove('is-active');
    }

    const body = document.getElementsByTagName('body')[0];
    body.classList.remove('modal-open');
  }

  function open(id: string) {
    const modal = document.getElementById(id)!;
    modal.classList.add('is-active');

    const body = document.getElementsByTagName('body')[0];
    body.classList.add('modal-open');
  }

  function toggle(id: string) {
    const modal = document.getElementById(id);
    modal!.classList.toggle('is-active');

    const body = document.getElementsByTagName('body')[0];
    body.classList.toggle('modal-open');
  }

  function ready() {
    const modalBackgrounds = document.getElementsByClassName(
      'non-react-modal-background'
    );

    Array.from(modalBackgrounds).forEach((modalBackground) => {
      (modalBackground as HTMLElement).onclick = (e) => {
        e.preventDefault();
        closeAll();
      };
    });
  }

  document.addEventListener('turbolinks:load', ready);

  return {
    closeAll,
    toggle,
    open
  };
})();

export default Modal;
