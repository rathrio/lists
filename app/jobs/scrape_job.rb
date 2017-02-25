class ScrapeJob < ApplicationJob
  queue_as :default

  def perform(*item_ids)
    item_ids.each do |id|
      Item.find(id).lucky_scrape
    end
  end
end
