require 'fileutils'

namespace :housekeeping do
  desc "Remove orphan uploads"
  task remove_stale_uploads: :environment do
    Rails.logger = Logger.new(STDOUT)

    known_ids = Item.with_deleted.pluck(:id).to_set
    num_items = known_ids.size

    base_item_uploads_path = "./public/uploads/item"

    %w[image backdrop_image].each do |mounted_as|
      image_dirs = Dir.entries("#{base_item_uploads_path}/#{mounted_as}")
        .reject { |dir| ['.', '..'].include? dir }
        .map(&:to_i).to_set

      ids_to_delete = image_dirs - known_ids
      if ids_to_delete.empty?
        Rails.logger.info("No stale item #{mounted_as}s found")
      else
        ids_to_delete.each do |id_to_delete|
          dir_to_delete = "#{base_item_uploads_path}/#{mounted_as}/#{id_to_delete}"
          if ENV["DO_IT_FOR_REAL"]
            FileUtils.rm_rf(dir_to_delete)
            Rails.logger.info("Deleted #{dir_to_delete}")
          else
            Rails.logger.info("Would have deleted '#{dir_to_delete}'. Rerun with DO_IT_FOR_REAL=1 to actually delete directories.")
          end
        end
      end
    end
  end
end
