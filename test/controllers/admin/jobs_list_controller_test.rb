require 'test_helper'

class Admin::JobsListControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  test 'unauthorized' do
    get :index
    assert_response :redirect
  end

  test 'no role' do
    sign_in(create(:user))
    get :index
    assert_response :redirect
  end

  test 'no developer role' do
    sign_in(create(:user_admin))
    get :index
    assert_response :redirect
  end

  test 'developer role' do
    sign_in(create(:user_admin, :developer))
    get :index
    assert_response :success
  end
end
