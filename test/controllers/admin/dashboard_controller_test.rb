require 'test_helper'

class Admin::DashboardControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  test 'index unauthorized' do
    get :index
    assert_response :redirect
  end

  test 'index no role' do
    sign_in(create(:user))
    get :index
    assert_response :success
  end

  test 'index' do
    sign_in(:user, create(:user_admin))
    get :index
    assert_response :success
    sign_out(:user)

    sign_in(:user, create(:user_manager))
    get :index
    assert_response :success
    sign_out(:user)

    sign_in(:user, create(:user_fin_manager))
    get :index
    assert_response :success
    sign_out(:user)

    sign_in(:user, create(:user_investor))
    get :index
    assert_response :success
    sign_out(:user)
  end
end
