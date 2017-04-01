class CreateConsumerScopes < ActiveRecord::Migration[5.0]
  def change
    create_table :consumer_scopes do |t|
      t.references :consumer, foreign_key: true
      t.references :scope, foreign_key: true

      t.timestamps
    end
  end
end
