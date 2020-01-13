class CreateShortUrls < ActiveRecord::Migration[5.2]
  def change
    create_table :short_urls do |t|
      t.text :original
      t.string :short
      t.string :ip_address
      t.integer :expiration
      t.text :title

      t.timestamps
    end
  end
end
