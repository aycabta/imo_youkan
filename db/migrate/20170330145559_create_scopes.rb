class CreateScopes < ActiveRecord::Migration[5.0]
  def change
    create_table :scopes do |t|
      t.references :consumer, foreign_key: true
      t.string :name

      t.timestamps
    end

    add_index :consumers, :name, unique: true
  end
end
