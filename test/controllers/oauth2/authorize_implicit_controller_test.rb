require 'test_helper'

class OAuth2AuthorizeImplicitControllerTest < ActionDispatch::IntegrationTest
  test 'should get login form on /oauth2/authorize for implicit without session' do
    sp = ServiceProvider.all.max{ |a, b| a.scopes.size <=> b.scopes.size }
    consumer = sp.consumers.first
    consumer.run_callbacks(:commit)
    params = {
      response_type: 'token',
      client_id: consumer.client_id_key,
      redirect_uri: consumer.redirect_uris.first.uri,
      scope: sp.scopes.map { |s| s.name }.join(' ')
    }
    get(oauth2_authorize_implicit_path(sp.id), params: params)
    assert_response(:success)
    assert_template(:authorize_login)
  end

  test 'should get token by JSON on /oauth2/authorize for implicit with session' do
    ldap_user = Fabricate(:great_user)
    post(login_path, params: { username: ldap_user.uid, password: ldap_user.userPassword })
    sp = ServiceProvider.all.max{ |a, b| a.scopes.size <=> b.scopes.size }
    consumer = sp.consumers.first
    params = {
      response_type: 'token',
      client_id: consumer.client_id_key,
      redirect_uri: consumer.redirect_uris.first.uri,
      scope: sp.scopes.map { |s| s.name }.join(' '),
      state: 'abcABC'
    }
    get(oauth2_authorize_implicit_path(sp.id), params: params)
    assert_response(:found)
    queries = URI.decode_www_form(URI.parse(response.location).fragment).to_h
    assert_not_nil(queries['access_token'])
    assert_equal('bearer', queries['token_type'])
    assert_match(/^\d+$/, queries['expires_in'])
    assert_equal(sp.scopes.map { |s| s.name }.join(' '), queries['scope'])
    assert_equal('abcABC', queries['state'])
  end

  test 'should fail /oauth2/authorize for implicit with unknown scopes with session' do
    ldap_user = Fabricate(:great_user)
    post(login_path, params: { username: ldap_user.uid, password: ldap_user.userPassword })
    sp = ServiceProvider.all.max{ |a, b| a.scopes.size <=> b.scopes.size }
    consumer = sp.consumers.first
    params = {
      response_type: 'token',
      client_id: consumer.client_id_key,
      redirect_uri: consumer.redirect_uris.first.uri,
      scope: sp.scopes.map { |s| s.name }.concat(['unknown', 'strange']).join(' '),
      state: 'abcABC'
    }
    get(oauth2_authorize_implicit_path(sp.id), params: params)
    assert_response(:found)
    queries = URI.decode_www_form(URI.parse(response.location).fragment).to_h
    assert_nil(queries['access_token'])
    assert_equal('invalid_scope', queries['error'])
    assert_equal('Unknown scopes: unknown, strange', queries['error_description'])
    assert_equal('abcABC', queries['state'])
    assert_equal(consumer.redirect_uris.first.uri, response.location[0..(response.location.rindex(?#) - 1)])
  end

  test 'should fail /oauth2/authorize for implicit without required params with session' do
    ldap_user = Fabricate(:great_user)
    post(login_path, params: { username: ldap_user.uid, password: ldap_user.userPassword })
    sp = ServiceProvider.all.max{ |a, b| a.scopes.size <=> b.scopes.size }
    consumer = sp.consumers.first
    params = {
      response_type: 'token',
      scope: sp.scopes.map { |s| s.name }.join(' '),
      state: 'abcABC'
    }
    get(oauth2_authorize_implicit_path(sp.id), params: params)
    assert_response(:bad_request)
    json = JSON.parse(response.body)
    assert_nil(params['access_token'])
    assert_equal('invalid_request', json['error'])
    assert_equal('client_id and redirect_uri are required', json['error_description'])
    assert_equal('abcABC', json['state'])
    params = {
      response_type: 'token',
      client_id: consumer.client_id_key,
      scope: sp.scopes.map { |s| s.name }.join(' '),
      state: 'abcABC'
    }
    get(oauth2_authorize_implicit_path(sp.id), params: params)
    assert_response(:bad_request)
    json = JSON.parse(response.body)
    assert_nil(params['access_token'])
    assert_equal('invalid_request', json['error'])
    assert_equal('redirect_uri is required', json['error_description'])
    assert_equal('abcABC', json['state'])
  end

  test 'should fail /oauth2/authorize for implicit with invalid client_id' do
    ldap_user = Fabricate(:great_user)
    post(login_path, params: { username: ldap_user.uid, password: ldap_user.userPassword })
    sp = ServiceProvider.all.max{ |a, b| a.scopes.size <=> b.scopes.size }
    consumer = sp.consumers.first
    client_id = consumer.client_id_key + 'invalidsuffix'
    params = {
      response_type: 'token',
      client_id: client_id,
      redirect_uri: consumer.redirect_uris.first.uri,
      scope: sp.scopes.map { |s| s.name }.concat(['unknown', 'strange']).join(' '),
      state: 'abcABC'
    }
    get(oauth2_authorize_implicit_path(sp.id), params: params)
    assert_response(:bad_request)
    json = JSON.parse(response.body)
    assert_nil(json['access_token'])
    assert_equal('invalid_request', json['error'])
    assert_equal("client_id (#{client_id}) is invalid", json['error_description'])
    assert_equal('abcABC', json['state'])
  end

  test 'should fail /oauth2/authorize for implicit with invalid redirect_uri' do
    ldap_user = Fabricate(:great_user)
    post(login_path, params: { username: ldap_user.uid, password: ldap_user.userPassword })
    sp = ServiceProvider.all.max{ |a, b| a.scopes.size <=> b.scopes.size }
    consumer = sp.consumers.first
    redirect_uri = consumer.redirect_uris.first.uri + 'invalidsuffix'
    params = {
      response_type: 'token',
      client_id: consumer.client_id_key,
      redirect_uri: redirect_uri,
      scope: sp.scopes.map { |s| s.name }.concat(['unknown', 'strange']).join(' '),
      state: 'abcABC'
    }
    get(oauth2_authorize_implicit_path(sp.id), params: params)
    assert_response(:bad_request)
    json = JSON.parse(response.body)
    assert_nil(json['access_token'])
    assert_equal('invalid_request', json['error'])
    assert_equal("redirect_uri (#{redirect_uri}) is invalid", json['error_description'])
    assert_equal('abcABC', json['state'])
  end
end
