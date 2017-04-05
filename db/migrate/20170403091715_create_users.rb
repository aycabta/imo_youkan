class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.references :token, foreign_key: true
      t.string :uid
      t.string :provider
      t.string :nickname
      t.string :email
      t.string :name
      t.string :image_url

      t.timestamps

      t.index :nickname, unique: true
      t.index :email, unique: true
    end
  end
end
