class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :uid
      t.string :email
      t.string :name

      t.timestamps

      t.index :uid, unique: true
    end
  end
end
