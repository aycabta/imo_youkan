class CreateConsumers < ActiveRecord::Migration[5.0]
  def change
    create_table :consumers do |t|
      t.references :service_provider, foreign_key: true
      t.string :name
      t.string :client_id_key
      t.string :client_secret

      t.timestamps
    end

    add_index :consumers, :client_id_key, unique: true
    add_index :consumers, :client_secret, unique: true
  end
end
