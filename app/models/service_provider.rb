class ServiceProvider < ApplicationRecord
  has_many :consumers
  has_many :scopes
end
