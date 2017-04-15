class CreateConsumers < ActiveRecord::Migration[5.0]
  def change
    create_table :consumers do |t|
      t.references :service_provider, foreign_key: true
      t.references :user, foreign_key: true, null: false
      t.string :name, null: false
      t.string :client_id_key
      t.string :client_secret
      t.integer :seconds_to_expire, default: 3600

      t.timestamps

      t.index :client_id_key, unique: true
      t.index :client_secret, unique: true
    end
  end
end
