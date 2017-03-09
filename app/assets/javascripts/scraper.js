(function() {
  function scrape(e) {
    var that = $(this);
    if (!that.data('scrape')) {
      return false;
    }

    delay(function() {
      var query = that.val();
      if (query.length < 3) {
        return false;
      }

      var url = that.data('scrape-path') + '?query=' + encodeURIComponent(query);
      Spinner.show('.scraper-results');
      $('.scraper-results').load(url);
    }, 500);
  }

  $(document).on('turbolinks:load', function() {
    // Start scraping interwebs for items after user has typed a certain number
    // of characters.
    $('.scraper-query').on('keyup', scrape);
  });
})();
