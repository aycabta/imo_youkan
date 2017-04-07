class CreateRedirectURLs < ActiveRecord::Migration[5.0]
  def change
    create_table :redirect_urls do |t|
      t.references :consumer, foreign_key: true
      t.string :url

      t.timestamps
    end
  end
end
