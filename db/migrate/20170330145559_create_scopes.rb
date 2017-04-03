class CreateScopes < ActiveRecord::Migration[5.0]
  def change
    create_table :scopes do |t|
      t.references :consumer, foreign_key: true
      t.string :name

      t.timestamps

      t.index :name, unique: true
    end
  end
end
