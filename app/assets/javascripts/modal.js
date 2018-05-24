var Modal = (function() {
  function closeAll() {
    var modals = document.getElementsByClassName('modal');
    for (let i = 0; i < modals.length; i++) {
      var modal = modals[i];
      modal.classList.remove('is-active');
    }
  }

  function open(id) {
    var modal = document.getElementById(id);
    modal.classList.add('is-active');
  }

  function toggle(id) {
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
