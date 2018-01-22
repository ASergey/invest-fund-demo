require 'test_helper'

class Admin::CurrenciesControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  setup do
    @usd = create(:currency_usd)
  end

  test 'currency unauthorized' do
    get :index
    assert_response :redirect
  end

  test 'currency no role' do
    sign_in(create(:user))
    get :index
    assert_response :redirect
  end

  test 'manager should see currencies list' do
    sign_in(create(:user_manager))
    get :index
    assert_response :success
    assert_includes @response.body, @usd.name
  end

  test 'should redirect from new currency form' do
    sign_in(create(:user_manager))
    get :new
    assert_response :redirect
  end

  test 'should open new currency form' do
    sign_in(create(:user_fin_manager))
    get :new
    assert_response :success
  end

  test 'should open edit for currency' do
    sign_in(create(:user_fin_manager))

    get :edit, params: { id: @usd.id }
    assert_response :success
    assert_includes @response.body, @usd.name
  end
end
