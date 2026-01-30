# frozen_string_literal: true

namespace :images do
  desc "Regenerate thumbnails for all items"
  task regenerate_thumbnails: :environment do
    Item.unscoped.find_each do |item|
      next unless item.image.present?

      begin
        item.image.recreate_versions!(:thumb)
        puts "Regenerated thumbnail for item #{item.id}"
      rescue => e
        puts "Error regenerating thumbnail for item #{item.id}: #{e.message}"
      end
    end
  end
end
