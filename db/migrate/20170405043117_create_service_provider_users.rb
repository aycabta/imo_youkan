class CreateServiceProviderUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :service_provider_users do |t|
      t.references :service_provider, foreign_key: true
      t.references :user, foreign_key: true
      t.boolean :is_owner, default: true, null: false

      t.timestamps

      t.index [:service_provider_id, :user_id], unique: true, name: 'index_sp_users_on_sp_id_and_user_id'
    end
  end
end
