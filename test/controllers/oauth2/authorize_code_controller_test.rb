require 'test_helper'

class OAuth2::AuthorizeCodeControllerTest < ActionDispatch::IntegrationTest
  test 'should get authorize page on /oauth2/authorize' do
    sign_in_as(:great_user)
    sp = ServiceProvider.all.max{ |a, b| a.scopes.size <=> b.scopes.size }
    consumer = sp.consumers.first
    redirect_uri = consumer.redirect_uris.first.uri
    params = {
      response_type: 'code',
      client_id: consumer.client_id_key,
      redirect_uri: redirect_uri,
      scope: sp.scopes.map{ |s| s.name }.join(' '),
      state: 'abcABC'
    }
    get(oauth2_authorize_code_path(sp.id), params: params)
    assert_response(:success)
    assert_template(:authorize)
  end

  test 'should fail authorize page on /oauth2/authorize with invalid client_id' do
    sign_in_as(:great_user)
    sp = ServiceProvider.all.max{ |a, b| a.scopes.size <=> b.scopes.size }
    consumer = sp.consumers.first
    redirect_uri = consumer.redirect_uris.first.uri
    params = {
      response_type: 'code',
      client_id: consumer.client_id_key + 'invalid',
      redirect_uri: redirect_uri,
      scope: sp.scopes.map{ |s| s.name }.join(' '),
      state: 'abcABC'
    }
    get(oauth2_authorize_code_path(sp.id), params: params)
    assert_response(:bad_request)
    json = JSON.parse(response.body)
    assert_equal('abcABC', json['state'])
    assert_equal('invalid_request', json['error'])
    assert_equal('client_id is invalid', json['error_description'])
  end

  test 'should fail authorize page on /oauth2/authorize with invalid redirect_uri' do
    sign_in_as(:great_user)
    sp = ServiceProvider.all.max{ |a, b| a.scopes.size <=> b.scopes.size }
    consumer = sp.consumers.first
    redirect_uri = consumer.redirect_uris.first.uri
    params = {
      response_type: 'code',
      client_id: consumer.client_id_key,
      redirect_uri: redirect_uri + 'invalid',
      scope: sp.scopes.map{ |s| s.name }.join(' '),
      state: 'abcABC'
    }
    get(oauth2_authorize_code_path(sp.id), params: params)
    assert_response(:bad_request)
    json = JSON.parse(response.body)
    assert_equal('abcABC', json['state'])
    assert_equal('invalid_request', json['error'])
    assert_equal('redirect_uri is invalid', json['error_description'])
  end

  test 'should get code on /oauth2/authorize for authorization code' do
    sign_in_as(:great_user)
    sp = ServiceProvider.all.max{ |a, b| a.scopes.size <=> b.scopes.size }
    consumer = sp.consumers.first
    redirect_uri = consumer.redirect_uris.first.uri
    params = {
      client_id: consumer.client_id_key,
      redirect_uri: redirect_uri,
      scope: sp.scopes.map{ |s| s.name }.join(' '),
      state: 'abcABC'
    }
    post(oauth2_authorize_code_path(sp.id), params: params)
    assert_response(:found)
    queries = URI.decode_www_form(URI.parse(response.location).query).to_h
    assert_not_nil(queries['code'])
    assert_equal('abcABC', queries['state'])
  end

  test 'should get login form on /oauth2/authorize for authorization code without session' do
    sp = ServiceProvider.all.max{ |a, b| a.scopes.size <=> b.scopes.size }
    consumer = sp.consumers.first
    consumer.run_callbacks(:commit)
    params = {
      response_type: 'code',
      client_id: consumer.client_id_key,
      redirect_uri: consumer.redirect_uris.first.uri,
      scope: sp.scopes.map { |s| s.name }.join(' '),
      state: 'abcABC'
    }
    get(oauth2_authorize_implicit_path(sp.id), params: params)
    assert_response(:success)
    assert_template(:authorize_login)
  end

  test 'should reject /oauth2/authorize for authorization code' do
    sign_in_as(:great_user)
    sp = ServiceProvider.all.max{ |a, b| a.scopes.size <=> b.scopes.size }
    consumer = sp.consumers.first
    redirect_uri = consumer.redirect_uris.first.uri
    params = {
      client_id: consumer.client_id_key,
      redirect_uri: redirect_uri,
      state: 'abcABC'
    }
    post(oauth2_unauthorized_path(sp.id), params: params)
    assert_response(:found)
    queries = URI.decode_www_form(URI.parse(response.location).fragment).to_h
    assert_nil(queries['access_token'])
    assert_equal('access_denied', queries['error'])
    assert_equal('Resource owner denied authorization', queries['error_description'])
    assert_equal('abcABC', queries['state'])
    assert_equal(consumer.redirect_uris.first.uri, response.location[0..(response.location.rindex(?#) - 1)])
  end
end
