class RedirectURI < ApplicationRecord
  self.table_name = 'redirect_uris'
  belongs_to :consumer

  validates :uri, uniqueness: { scope: [:consumer_id] }
end
