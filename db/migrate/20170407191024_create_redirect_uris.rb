class CreateRedirectURIs < ActiveRecord::Migration[5.0]
  def change
    create_table :redirect_uris do |t|
      t.references :consumer, foreign_key: true
      t.string :uri

      t.timestamps
    end
  end
end
