require 'test_helper'

class OAuth2ControllerTest < ActionDispatch::IntegrationTest
  test 'should fail /oauth2/token without Content-Type' do
    get(oauth2_authorize_path(ServiceProvider.first.id))
    assert_response(:bad_request)
    json = JSON.parse(response.body)
    assert_equal('invalid_request', json['error'])
    assert_equal('Request header validation failed.', json['error_description'])
    assert_equal(' is invalid', json['error_details']['content_type'])
    assert_equal('error', json['status'])
  end

  test 'should fail /oauth2/token without response_type' do
    headers = { CONTENT_TYPE: 'application/x-www-form-urlencoded' }
    get(oauth2_authorize_path(ServiceProvider.first.id), headers: headers)
    assert_response(:bad_request)
    json = JSON.parse(response.body)
    assert_equal('invalid_request', json['error'])
    assert_equal('response_type is required', json['error_description'])
  end

  test 'should fail /oauth2/token with unknown response_type' do
    headers = { CONTENT_TYPE: 'application/x-www-form-urlencoded' }
    params = { response_type: 'unknown_type' }
    get(oauth2_authorize_path(ServiceProvider.first.id), headers: headers, params: params)
    assert_response(:bad_request)
    json = JSON.parse(response.body)
    assert_equal('invalid_request', json['error'])
    assert_equal('unknown_type is unknown', json['error_description'])
  end
end
