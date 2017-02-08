(function() {
  function filter(e) {
    var input = $(this);
    var text = input.val();
    var filterContainer = input.data('filter-container');
    var filterAttribute = 'data-filter-' + input.data('filter-attribute');
    var elements = $(filterContainer + ' > *[' + filterAttribute + ']')

    if (text.length === 0) {
      elements.show();
    } else {
      elements.hide();

      elements.filter(function() {
        return $(this).attr(filterAttribute).toLowerCase().match(text.toLowerCase());
      }).show();
    }
  }

  function ready() {
    console.log('foobar');
    $('.filter').on('keyup', filter);
  }

  $(document).ready(ready);
  $(document).on('turbolinks:load', ready);
})();
