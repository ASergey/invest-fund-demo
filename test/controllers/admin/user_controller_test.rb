require 'test_helper'

class Admin::UsersControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  setup do
    @manager  = create(:user_manager)
    @investor = create(:user_investor)
  end

  test 'users unauthorized' do
    get :index
    assert_response :redirect
  end

  test 'users no role' do
    sign_in(create(:user))
    get :index
    assert_response :redirect
  end

  test 'manager list users' do
    sign_in(@manager)

    get :index
    assert_response :success
    assert_includes @response.body, @investor.email
    assert_not_includes @response.body, @manager.email
  end

  test 'admin list users' do
    admin_user = create(:user_admin)
    sign_in(admin_user)

    get :index
    assert_response :success
    assert_includes @response.body, @investor.email
    assert_includes @response.body, @manager.email
    assert_includes @response.body, admin_user.email
  end

  test 'show user (manager)' do
    sign_in(@manager)
    get :show, params: { id: @investor.id }

    assert_response :success
    assert_includes @response.body, @investor.name
  end

  test 'new user form (manager)' do
    sign_in(@manager)
    get :new

    assert_response :success
  end

  test 'edit user form' do
    sign_in(@manager)

    get :edit, params: { id: @investor.id }
    assert_response :success
    assert_includes @response.body, @investor.name
  end

  test 'create operation successfully' do
    sign_in(@manager)

    assert_difference('User.count') do
      post :create, params: {
        user: {
          email: 'test@email.com',
          name:  'test name',
          password: '123456',
          password_confirmation: '123456',
          phone: '1234567890'
        }
      }
    end

    user = User.last
    assert_redirected_to admin_user_path(user)
  end

  test 'create user failed' do
    sign_in(@manager)

    assert_no_difference('User.count') do
      post :create, params: {
        user: {
          email: 'test@email.com'
        }
      }
    end

    assert_response :success
  end

  test 'list_investor_wallets success' do
    sign_in(@manager)
    create(:investor_wallet, user: @investor)
    get :list_investor_wallets, params: { id: @investor.id }

    response_body = JSON.parse(@response.body)
    assert_response :success
    assert_not_empty response_body['wallets']
  end

  test 'list_investor_wallets fail' do
    sign_in(@manager)
    create(:investor_wallet, user: @investor)
    get :list_investor_wallets, params: { id: @manager.id }

    assert_response :unprocessable_entity
    responce_body = JSON.parse(@response.body)
    assert_not_empty responce_body
  end
end
