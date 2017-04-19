require 'test_helper'

class ServiceProvidersControllerTest < ActionDispatch::IntegrationTest
  test 'should get root without login' do
    get(root_path)
    assert_response(:success)
    assert_nil(assigns(:sps))
    assert_not_nil(assigns(:new_sp))
  end
end
