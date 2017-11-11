var Spinner = function() {
  return {
    show: function(dom) {
      $(dom).html('<div class="columns"> <div class="column is-1 is-offset-5"> <span class="icon is-large"> <i class="fa fa-spinner fa-pulse fa-3x"></i> </span> </div> </div>');
    }
  };
}();
