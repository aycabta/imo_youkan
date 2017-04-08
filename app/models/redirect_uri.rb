class RedirectURI < ApplicationRecord
  self.table_name = 'redirect_uris'
  belongs_to :consumer
end
