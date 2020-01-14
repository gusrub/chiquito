class AddVisitCountToShortUrl < ActiveRecord::Migration[5.2]
  def change
    add_column :short_urls, :visit_count, :integer, default: 0
  end
end
