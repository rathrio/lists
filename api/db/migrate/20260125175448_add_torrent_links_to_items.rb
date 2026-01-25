class AddTorrentLinksToItems < ActiveRecord::Migration[8.0]
  def change
    add_column :items, :torrent_links, :jsonb, default: []
  end
end
