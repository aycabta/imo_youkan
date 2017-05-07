require 'test_helper'

class OAuth2::TokenControllerTest < ActionDispatch::IntegrationTest
  test 'should fail /oauth2/token with invalid Content-Type' do
    post(oauth2_token_path(ServiceProvider.first.id), headers: { 'CONTENT_TYPE': 'text/plain' })
    assert_response(:bad_request)
    json = JSON.parse(response.body)
    assert_equal('invalid_request', json['error'])
    assert_equal('Request header validation failed.', json['error_description'])
    assert_equal('text/plain is invalid, must be application/x-www-form-urlencoded', json['error_details']['content_type'])
    assert_equal('error', json['status'])
  end

  test 'should fail /oauth2/token with invalid_grant' do
    sp = ServiceProvider.all.max{ |a, b| a.scopes.size <=> b.scopes.size }
    consumer = sp.consumers.first
    params = {
      client_id: consumer.client_id_key,
      client_secret: consumer.client_secret,
      state: 'abcABC'
    }
    post(oauth2_token_path(sp), params: params)
    assert_response(:bad_request)
    json = JSON.parse(response.body)
    assert_equal('invalid_grant', json['error'])
    assert_equal('grant_type is invalid', json['error_description'])
  end

  test 'should get /oauth2/token with client_credentials' do
    sp = ServiceProvider.all.max{ |a, b| a.scopes.size <=> b.scopes.size }
    consumer = sp.consumers.first
    params = {
      grant_type: 'client_credentials',
      client_id: consumer.client_id_key,
      client_secret: consumer.client_secret,
      state: 'abcABC'
    }
    post(oauth2_token_path(sp), params: params)
    assert_response(:success)
    json = JSON.parse(response.body)
    assert_not_nil(json['access_token'])
    assert_equal('Bearer', json['token_type'])
    assert_kind_of(Integer, json['expires_in'])
    assert_equal('abcABC', json['state'])
  end
end

