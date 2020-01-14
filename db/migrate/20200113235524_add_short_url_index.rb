class AddShortUrlIndex < ActiveRecord::Migration[5.2]
  def change
    add_index(:short_urls, :short)
  end
end
