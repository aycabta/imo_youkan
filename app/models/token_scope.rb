class TokenScope < ApplicationRecord
  belongs_to :token
  belongs_to :scope
end
