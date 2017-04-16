class Scope < ApplicationRecord
  belongs_to :service_provider

  validates :service_provider_id, uniqueness: { scope: [:name] }
end
