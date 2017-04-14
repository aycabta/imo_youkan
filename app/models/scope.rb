class Scope < ApplicationRecord
  belongs_to :service_provider

  validates :name, uniqueness: true
end
