require 'test_helper'

class TokenTest < ActiveSupport::TestCase
  test '#set_as_client_credentials is well-behaved' do
    sp = ServiceProvider.create!(name: 'a web service')
    consumer = Consumer.create!(name: 'a consumer', service_provider: sp, owner: User.create!)
    token = Token.new(consumer: consumer)
    token.set_as_client_credentials
    assert_equal(token.grant, 'client_credentials')
    assert_not_nil(token.access_token)
    assert_kind_of(String, token.access_token)
    assert_nil(token.refresh_token)
    assert_kind_of(Time, token.expires_in)
  end

  test '#set_as_implicit is well-behaved' do
    scopes = %w(basic profile data)
    redirect_uri = 'http://foo.com/'
    state = 'teststate'
    sp = ServiceProvider.create!(name: 'a web service')
    scopes.each { |name| sp.scopes.create!(name: name) }
    consumer = Consumer.create!(name: 'a consumer', service_provider: sp, owner: User.create!)
    consumer.redirect_uris.create!(uri: redirect_uri)
    token = Token.new(consumer: consumer)
    token.set_as_implicit(scopes, state, redirect_uri)
    assert_equal(token.grant, 'implicit')
    assert_equal(token.state, state)
    assert_not_nil(token.access_token)
    assert_kind_of(String, token.access_token)
    assert_nil(token.refresh_token)
    token.approved_scopes.each do |scope|
      assert(scopes.include?(scope.name))
    end
    assert_equal(token.redirect_uri.uri, redirect_uri)
    assert_kind_of(Time, token.expires_in)
  end

  test '#set_as_implicit with partial scopes is well-behaved' do
    scopes = %w(basic profile data post)
    partial_scopes = scopes[0, 2]
    redirect_uri = 'http://foo.com/'
    state = 'teststate'
    sp = ServiceProvider.create!(name: 'a web service')
    scopes.each { |name| sp.scopes.create!(name: name) }
    consumer = Consumer.create!(name: 'a consumer', service_provider: sp, owner: User.create!)
    consumer.redirect_uris.create!(uri: redirect_uri)
    token = Token.new(consumer: consumer)
    token.set_as_implicit(partial_scopes, state, redirect_uri)
    assert_equal(token.grant, 'implicit')
    assert_equal(token.state, state)
    assert_not_nil(token.access_token)
    assert_kind_of(String, token.access_token)
    assert_nil(token.refresh_token)
    token.approved_scopes.each do |scope|
      assert_not_nil(partial_scopes.delete(scope.name))
    end
    assert_empty(partial_scopes)
    assert_equal(token.redirect_uri.uri, redirect_uri)
    assert_kind_of(Time, token.expires_in)
  end

  test '#set_as_authorization_code is well-behaved' do
    scopes = %w(basic profile data)
    redirect_uri = 'http://foo.com/'
    state = 'teststate'
    sp = ServiceProvider.create!(name: 'a web service')
    scopes.each { |name| sp.scopes.create!(name: name) }
    consumer = Consumer.create!(name: 'a consumer', service_provider: sp, owner: User.create!)
    consumer.redirect_uris.create!(uri: redirect_uri)
    token = Token.new(consumer: consumer)
    token.set_as_authorization_code(scopes, state, redirect_uri)
    assert_equal(token.grant, 'authorization_code')
    assert_equal(token.state, state)
    assert_not_nil(token.code)
    assert_kind_of(String, token.code)
    assert_nil(token.access_token)
    assert_nil(token.refresh_token)
    token.approved_scopes.each do |scope|
      assert(scopes.include?(scope.name))
    end
    assert_equal(token.redirect_uri.uri, redirect_uri)
    assert_nil(token.expires_in)
  end

  test '#set_as_authorization_code with partial scopes is well-behaved' do
    scopes = %w(basic profile data post)
    partial_scopes = scopes[0, 2]
    redirect_uri = 'http://foo.com/'
    state = 'teststate'
    sp = ServiceProvider.create!(name: 'a web service')
    scopes.each { |name| sp.scopes.create!(name: name) }
    consumer = Consumer.create!(name: 'a consumer', service_provider: sp, owner: User.create!)
    consumer.redirect_uris.create!(uri: redirect_uri)
    token = Token.new(consumer: consumer)
    token.set_as_authorization_code(partial_scopes, state, redirect_uri)
    assert_equal(token.grant, 'authorization_code')
    assert_equal(token.state, state)
    assert_not_nil(token.code)
    assert_kind_of(String, token.code)
    assert_nil(token.access_token)
    assert_nil(token.refresh_token)
    token.approved_scopes.each do |scope|
      assert_not_nil(partial_scopes.delete(scope.name))
    end
    assert_empty(partial_scopes)
    assert_equal(token.redirect_uri.uri, redirect_uri)
    assert_nil(token.expires_in)
  end

  test '#set_tokens_for_authorization_code is well-behaved' do
    scopes = %w(basic profile data)
    redirect_uri = 'http://foo.com/'
    state = 'teststate'
    sp = ServiceProvider.create!(name: 'a web service')
    scopes.each { |name| sp.scopes.create!(name: name) }
    consumer = Consumer.create!(name: 'a consumer', service_provider: sp, owner: User.create!)
    consumer.redirect_uris.create!(uri: redirect_uri)
    token = Token.new(consumer: consumer)
    token.set_as_authorization_code(scopes, state, redirect_uri)
    token.set_tokens_for_authorization_code
    assert_equal(token.grant, 'authorization_code')
    assert_equal(token.state, state)
    assert_not_nil(token.code)
    assert_kind_of(String, token.code)
    assert_not_nil(token.access_token)
    assert_not_nil(token.refresh_token)
    token.approved_scopes.each do |scope|
      assert(scopes.include?(scope.name))
    end
    assert_equal(token.redirect_uri.uri, redirect_uri)
    assert_kind_of(Time, token.expires_in)
  end

  test '#set_tokens_for_authorization_code without code is ill-behaved' do
    scopes = %w(basic profile data)
    redirect_uri = 'http://foo.com/'
    state = 'teststate'
    sp = ServiceProvider.create!(name: 'a web service')
    scopes.each { |name| sp.scopes.create!(name: name) }
    consumer = Consumer.create!(name: 'a consumer', service_provider: sp, owner: User.create!)
    consumer.redirect_uris.create!(uri: redirect_uri)
    token = Token.new(consumer: consumer)
    token.grant = 'authorization_code'
    assert_raise ActiveRecord::RecordInvalid do
      token.set_tokens_for_authorization_code
    end
    assert_kind_of(Time, token.expires_in)
  end
end
