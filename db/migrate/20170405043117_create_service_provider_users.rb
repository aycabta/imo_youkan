class CreateServiceProviderUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :service_provider_users do |t|
      t.references :service_provider, foreign_key: true
      t.references :user, foreign_key: true
      t.boolean :is_owner, default: true, null: false

      t.timestamps
    end
  end
end
