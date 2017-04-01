class ClientScope < ApplicationRecord
  belongs_to :consumer
  belongs_to :scope
end
