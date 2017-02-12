(function() {
  function scrape(e) {
    var query = $('.scraper-query').val();
    var url = $(this).attr('href') + '?query=' + encodeURIComponent(query);
    $('.scraper-results').load(url);
    e.preventDefault();
  }

  function ready() {
    $('.scraper-link').on('click', scrape);
  }

  $(document).on('turbolinks:load', ready);
})();
