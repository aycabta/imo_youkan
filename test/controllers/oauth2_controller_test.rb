require 'test_helper'

class OAuth2ControllerTest < ActionDispatch::IntegrationTest
  test 'should fail /oauth2/authorize without response_type' do
    get(oauth2_authorize_path(ServiceProvider.first.id))
    assert_response(:bad_request)
    json = JSON.parse(response.body)
    assert_equal('invalid_request', json['error'])
    assert_equal('response_type is required', json['error_description'])
  end

  test 'should fail /oauth2/authorize with unknown response_type' do
    params = { response_type: 'unknown_type' }
    get(oauth2_authorize_path(ServiceProvider.first.id), params: params)
    assert_response(:bad_request)
    json = JSON.parse(response.body)
    assert_equal('unsupported_response_type', json['error'])
    assert_equal('unknown_type is unknown', json['error_description'])
  end

  test 'should deny access to /oauth2/unauthorize' do
    sp = ServiceProvider.first
    consumer = sp.consumers.first
    params = {
      client_id: consumer.client_id_key,
      redirect_uri: consumer.redirect_uris.first.uri,
      state: 'abcABC'
    }
    post(oauth2_unauthorized_path(sp), params: params)
    assert_response(:found)
    queries = URI.decode_www_form(URI.parse(response.location).fragment).to_h
    assert_equal('access_denied', queries['error'])
    assert_equal('Resource owner denied authorization', queries['error_description'])
    assert_equal('abcABC', queries['state'])
  end

  test 'should fail to /oauth2/unauthorize with unknown client_id' do
    sp = ServiceProvider.first
    consumer = sp.consumers.first
    params = {
      client_id: consumer.client_id_key + 'unknown',
      redirect_uri: consumer.redirect_uris.first.uri,
      state: 'abcABC'
    }
    post(oauth2_unauthorized_path(sp), params: params)
    assert_response(:bad_request)
    json = JSON.parse(response.body)
    assert_equal('invalid_request', json['error'])
    assert_equal("client_id is unknown", json['error_description'])
    assert_equal('abcABC', json['state'])
  end

  test 'should fail to /oauth2/unauthorize with unknown redirect_uri' do
    sp = ServiceProvider.first
    consumer = sp.consumers.first
    redirect_uri = consumer.redirect_uris.first.uri + 'unknown'
    params = {
      client_id: consumer.client_id_key,
      redirect_uri: redirect_uri,
      state: 'abcABC'
    }
    post(oauth2_unauthorized_path(sp), params: params)
    assert_response(:bad_request)
    json = JSON.parse(response.body)
    assert_equal('invalid_request', json['error'])
    assert_equal("redirect_uri is unknown", json['error_description'])
    assert_equal('abcABC', json['state'])
  end

  test 'should get /oauth2/introspect with client_credentials' do
    ldap_user = sign_in_as(:great_user)
    sp = ServiceProvider.all.max{ |a, b| a.scopes.size <=> b.scopes.size }
    consumer = sp.consumers.first
    user = User.find_by(uid: ldap_user.uid)
    token = consumer.tokens.create
    redirect_uri = consumer.redirect_uris.first.uri
    state = 'abcABC'
    token.set_as_client_credentials
    params = {
      client_id: consumer.client_id_key,
      client_secret: consumer.client_secret,
      token: token.access_token,
      state: state
    }
    post(oauth2_introspect_path(sp), params: params)
    json = JSON.parse(response.body)
    assert_equal(true, json['active'])
    assert_equal('', json['scope'])
    assert_equal(state, json['state'])
  end

  test 'should get /oauth2/introspect with implicit' do
    ldap_user = sign_in_as(:great_user)
    sp = ServiceProvider.all.max{ |a, b| a.scopes.size <=> b.scopes.size }
    consumer = sp.consumers.first
    user = User.find_by(uid: ldap_user.uid)
    token = consumer.tokens.create!(grant: 'implicit', user: user)
    redirect_uri = consumer.redirect_uris.first.uri
    scopes = sp.scopes.map{ |s| s.name }
    state = 'abcABC'
    token.set_as_implicit(scopes, state, redirect_uri)
    params = {
      client_id: consumer.client_id_key,
      client_secret: consumer.client_secret,
      token: token.access_token,
      state: state
    }
    post(oauth2_introspect_path(sp), params: params)
    json = JSON.parse(response.body)
    assert_equal(true, json['active'])
    assert_equal(scopes.join(' '), json['scope'])
    assert_equal(redirect_uri, json['redirect_uri'])
    assert_equal(ldap_user['uid'], json['user']['uid'])
    assert_equal(state, json['state'])
  end

  test 'should fail /oauth2/introspect with invalid token' do
    ldap_user = sign_in_as(:great_user)
    sp = ServiceProvider.all.max{ |a, b| a.scopes.size <=> b.scopes.size }
    consumer = sp.consumers.first
    user = User.find_by(uid: ldap_user.uid)
    token = consumer.tokens.create
    state = 'abcABC'
    token.set_as_client_credentials
    params = {
      client_id: consumer.client_id_key,
      client_secret: consumer.client_secret,
      token: token.access_token + 'invalid',
      state: state
    }
    post(oauth2_introspect_path(sp), params: params)
    json = JSON.parse(response.body)
    assert_equal(false, json['active'])
    assert_equal(state, json['state'])
  end

  test 'should fail /oauth2/introspect with expired token' do
    ldap_user = sign_in_as(:great_user)
    sp = ServiceProvider.all.max{ |a, b| a.scopes.size <=> b.scopes.size }
    consumer = sp.consumers.first
    user = User.find_by(uid: ldap_user.uid)
    token = consumer.tokens.create
    state = 'abcABC'
    token.set_as_client_credentials
    token.expires_in = 1.day.ago
    token.save
    params = {
      client_id: consumer.client_id_key,
      client_secret: consumer.client_secret,
      token: token.access_token,
      state: state
    }
    post(oauth2_introspect_path(sp), params: params)
    json = JSON.parse(response.body)
    assert_equal(false, json['active'])
    assert_equal(state, json['state'])
  end

  test 'should fail /oauth2/introspect with invalid client_secret' do
    ldap_user = sign_in_as(:great_user)
    sp = ServiceProvider.all.max{ |a, b| a.scopes.size <=> b.scopes.size }
    consumer = sp.consumers.first
    user = User.find_by(uid: ldap_user.uid)
    token = consumer.tokens.create
    state = 'abcABC'
    token.set_as_client_credentials
    params = {
      client_id: consumer.client_id_key,
      client_secret: consumer.client_secret + 'invalid',
      token: token.access_token + 'invalid',
      state: state
    }
    post(oauth2_introspect_path(sp), params: params)
    json = JSON.parse(response.body)
    assert_equal('invalid_request', json['error'])
    assert_equal('client_id or client_secret is invalid', json['error_description'])
  end

  test 'should success /oauth2/revoke' do
    ldap_user = sign_in_as(:great_user)
    sp = ServiceProvider.all.max{ |a, b| a.scopes.size <=> b.scopes.size }
    consumer = sp.consumers.first
    user = User.find_by(uid: ldap_user.uid)
    token = consumer.tokens.create!(grant: 'implicit', user: user)
    redirect_uri = consumer.redirect_uris.first.uri
    scopes = sp.scopes.map{ |s| s.name }
    state = 'abcABC'
    token.set_as_implicit(scopes, state, redirect_uri)
    params = {
      client_id: consumer.client_id_key,
      client_secret: consumer.client_secret,
      token: token.access_token,
      state: state
    }
    post(oauth2_revoke_path(sp), params: params)
    json = JSON.parse(response.body)
    assert_equal(true, json['success'])
    assert_equal(state, json['state'])
  end

  test 'should fail /oauth2/revoke with invalid access_token' do
    ldap_user = sign_in_as(:great_user)
    sp = ServiceProvider.all.max{ |a, b| a.scopes.size <=> b.scopes.size }
    consumer = sp.consumers.first
    user = User.find_by(uid: ldap_user.uid)
    token = consumer.tokens.create!(grant: 'implicit', user: user)
    redirect_uri = consumer.redirect_uris.first.uri
    scopes = sp.scopes.map{ |s| s.name }
    state = 'abcABC'
    token.set_as_implicit(scopes, state, redirect_uri)
    params = {
      client_id: consumer.client_id_key,
      client_secret: consumer.client_secret,
      token: token.access_token + 'invalid',
      state: state
    }
    post(oauth2_revoke_path(sp), params: params)
    json = JSON.parse(response.body)
    assert_equal('invalid_request', json['error'])
    assert_equal('token is invalid', json['error_description'])
    assert_equal(state, json['state'])
  end
end
