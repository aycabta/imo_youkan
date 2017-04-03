class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :username
      t.string :password_hash
      t.string :realname
      t.string :email

      t.timestamps

      t.index :username, unique: true
      t.index :email, unique: true
    end
  end
end
