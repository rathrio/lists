const Modal = (() => {
  function closeAll() {
    const modals = document.getElementsByClassName('modal');
    for (let i = 0; i < modals.length; i += 1) {
      const modal = modals[i];
      modal.classList.remove('is-active');
    }
  }

  function open(id: string) {
    const modal = document.getElementById(id);
    modal!.classList.add('is-active');
  }

  function toggle(id: string) {
    const modal = document.getElementById(id);
    modal!.classList.toggle('is-active');
  }

  function ready() {
    const modalBackground = document.getElementsByClassName(
      'modal-background',
    )[0] as HTMLElement;

    modalBackground.onclick = (e) => {
      e.preventDefault();
      closeAll();
    };
  }

  document.addEventListener('turbolinks:load', ready);

  return {
    closeAll,
    toggle,
    open,
  };
})();

export default Modal;
