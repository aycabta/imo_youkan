require 'securerandom'

class Token < ApplicationRecord
  belongs_to :consumer
  has_many :approved_scopes, :through => :token_scopes
end
