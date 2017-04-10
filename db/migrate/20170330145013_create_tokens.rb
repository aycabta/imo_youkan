class CreateTokens < ActiveRecord::Migration[5.0]
  def change
    create_table :tokens do |t|
      t.references :consumer, foreign_key: true
      t.references :user, foreign_key: true
      t.datetime :expires_in
      t.string :grant
      t.string :state
      t.string :code
      t.string :token_type
      t.string :access_token
      t.string :token_type
      t.string :refresh_token

      t.timestamps

      t.index [:consumer_id, :access_token], unique: true
      t.index [:consumer_id, :refresh_token], unique: true
    end
  end
end
