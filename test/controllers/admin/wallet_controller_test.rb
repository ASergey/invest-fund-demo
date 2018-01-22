require 'test_helper'

class Admin::WalletsControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  setup do
    @fund_wallet = create(:wallet)
  end

  test 'unauthorized' do
    get :index
    assert_response :redirect
  end

  test 'no role' do
    sign_in(create(:user))
    get :index
    assert_response :redirect
  end

  test 'manager should see wallets list' do
    sign_in(create(:user_manager))
    get :index
    assert_response :success
    assert_includes @response.body, @fund_wallet.name
  end

  test 'manager show wallet' do
    sign_in(create(:user_manager))
    get :show, params: { id: @fund_wallet.id }
    assert_response :success
    assert_includes @response.body, @fund_wallet.name
  end

  test 'should redirect from new wallets form' do
    sign_in(create(:user_manager))
    get :new
    assert_response :redirect
  end

  test 'should open new wallets form' do
    sign_in(create(:user_fin_manager))
    get :new
    assert_response :success
  end

  test 'should open edit for fund wallet' do
    sign_in(create(:user_fin_manager))

    get :edit, params: { id: @fund_wallet.id }
    assert_response :success
    assert_includes @response.body, @fund_wallet.address
  end

  test 'wallets_by_currency success' do
    sign_in(create(:user_fin_manager))

    get :wallets_by_currency, params: { currency_id: @fund_wallet.currency.id }, xhr: true

    response_body = JSON.parse(@response.body)
    assert_response :success
    assert_not_empty response_body['wallets']
    assert_equal @fund_wallet.id, response_body['wallets'].first['id']
  end

  test 'wallets_by_currency fail not enough params' do
    sign_in(create(:user_fin_manager))

    get :wallets_by_currency, xhr: true

    response_body = JSON.parse(@response.body)
    assert_response :unprocessable_entity
    assert_not_empty response_body
  end

  test 'wallets_by_currency not found' do
    sign_in(create(:user_fin_manager))

    get :wallets_by_currency, params: { currency_id: create(:currency).id }, xhr: true
    assert_response :success
    response_body = JSON.parse(@response.body)
    assert_not_empty response_body
    assert_empty response_body['wallets']
  end
end
