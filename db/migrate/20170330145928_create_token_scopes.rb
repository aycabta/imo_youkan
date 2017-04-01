class CreateTokenScopes < ActiveRecord::Migration[5.0]
  def change
    create_table :token_scopes do |t|
      t.references :token, foreign_key: true
      t.references :scope, foreign_key: true

      t.timestamps
    end
  end
end
