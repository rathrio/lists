# frozen_string_literal: true

# The Prowlarr magnet-link feature is retired — downloads go through
# Jellyseerr now (see the availability endpoints).
class RemoveTorrentLinksFromItems < ActiveRecord::Migration[8.0]
  def change
    remove_column :items, :torrent_links, :jsonb, default: []
  end
end
