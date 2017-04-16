require 'test_helper'

class TokenTest < ActiveSupport::TestCase
  test '#set_as_client_credentials is well-behaved' do
    token = Token.new(consumer: Consumer.new)
    token.set_as_client_credentials
    assert_equal(token.grant, 'client_credentials')
    assert_not_nil(token.access_token)
    assert_kind_of(String, token.access_token)
    assert_nil(token.refresh_token)
  end
end
