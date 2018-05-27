var Modal = (function() {
  function closeAll() {
    const modals = document.getElementsByClassName('modal');
    for (let i = 0; i < modals.length; i++) {
      const modal = modals[i];
      modal.classList.remove('is-active');
    }
  }

  function open(id) {
    var modal = document.getElementById(id);
    modal.classList.add('is-active');
  }

  function toggle(id) {
    console.log("GOT HERE");
    var modal = document.getElementById(id);
    modal.classList.toggle('is-active');
  }

  function ready() {
    var modalBackground = document.getElementsByClassName('modal-background')[0];
    modalBackground.onclick = function(e) {
      e.preventDefault();
      closeAll();
    };
  }

  document.addEventListener("turbolinks:load", function() {
    ready()
  });

  return {
    closeAll: closeAll,
    toggle: toggle,
    open: open
  };
})();
