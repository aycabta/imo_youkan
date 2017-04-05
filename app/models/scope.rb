class Scope < ApplicationRecord
  belongs_to :service_provider
  has_many :approved_token, :through => :token_scopes
end
