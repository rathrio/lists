(function() {
  function scrape(e) {
    if (e.which != 13) {
      return true;
    }

    var that = $(this);
    if (!that.data('scrape')) {
      return false;
    }

    var query = that.val();

    // Don't trigger scraping if query is less than two chars long.
    if (query.length < 2) {
      return false;
    }

    var url = that.data('scrape-path') + '?query=' + encodeURIComponent(query);
    Spinner.show('.scraper-results');
    $('.scraper-results').load(url);

    return false;
  }

  $(document).on('turbolinks:load', function() {
    // Start scraping interwebs for items on enter.
    $('.scraper-query').on('keydown', scrape);
  });
})();
