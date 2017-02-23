class ScrapeJob < ApplicationJob
  queue_as :default

  def perform(*items)
    items.each(&:lucky_scrape)
  end
end
