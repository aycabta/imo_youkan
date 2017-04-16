require 'test_helper'

class TokenTest < ActiveSupport::TestCase
  test '#set_as_client_credentials is well-behaved' do
    sp = ServiceProvider.create!(name: 'a web service')
    consumer = Consumer.create!(name: 'a consumer', service_provider: sp, owner: User.create)
    token = Token.new(consumer: consumer)
    token.set_as_client_credentials
    assert_equal(token.grant, 'client_credentials')
    assert_not_nil(token.access_token)
    assert_kind_of(String, token.access_token)
    assert_nil(token.refresh_token)
  end

  test '#set_as_implicit is well-behaved' do
    scopes = %w(basic profile data)
    redirect_uri = 'http://foo.com/'
    sp = ServiceProvider.create!(name: 'a web service')
    scopes.each { |name| sp.scopes.create!(name: name) }
    consumer = Consumer.create!(name: 'a consumer', service_provider: sp, owner: User.create)
    consumer.redirect_uris.create!(uri: redirect_uri)
    token = Token.create!(grant: 'implicit', consumer: consumer)
    token.save
    token.set_as_implicit(scopes, 'teststate', redirect_uri)
    assert_equal(token.grant, 'implicit')
    assert_not_nil(token.access_token)
    assert_kind_of(String, token.access_token)
    assert_nil(token.refresh_token)
    token.approved_scopes.each do |scope|
      assert(scopes.include?(scope.name))
    end
    assert_equal(token.redirect_uri.uri, redirect_uri)
  end
end
