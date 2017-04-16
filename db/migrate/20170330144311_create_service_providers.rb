class CreateServiceProviders < ActiveRecord::Migration[5.0]
  def change
    create_table :service_providers do |t|
      t.string :name, null: false

      t.timestamps

      t.index :name, unique: true
    end
  end
end
