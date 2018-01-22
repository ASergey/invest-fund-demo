require 'test_helper'

class Admin::ExchangeOperationsControllerTest < ActionController::TestCase
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

  test 'operations list' do
    sign_in(create(:user_manager))
    get :index
    assert_response :success
  end

  test 'show' do
    sign_in(create(:user_manager))
    get :show, params: { id: create(:exchange_operation).id }

    assert_response :success
  end

  test 'new redirect' do
    sign_in(create(:user_manager))
    get :new
    assert_response :redirect
  end

  test 'new success' do
    sign_in(create(:user_fin_manager))
    get :new
    assert_response :success
  end

  test 'create redirect' do
    sign_in(create(:user_manager))
    post :create, params: { exchange_operation: {} }
    assert_response :redirect
  end

  test 'create fail' do
    fin_manager = create(:user_fin_manager)
    sign_in(fin_manager)

    assert_no_difference('ExchangeOperation.count') do
      post :create, params: {
        exchange_operation: {
          user_id:          fin_manager.id,
          from_currency_id: create(:currency).id
        }
      }
    end

    assert_response :success
  end

  test 'create success' do
    fin_manager = create(:user_fin_manager)
    currency1   = create(:currency)
    currency2   = create(:currency)

    create(:exchange_rate, from_currency: currency1, to_currency: currency2)

    sign_in(fin_manager)
    assert_difference('ExchangeOperation.count') do
      post :create, params: {
        exchange_operation: {
          user_id:             fin_manager.id,
          from_currency_id:    currency1.id,
          to_currency_id:      currency2.id,
          fund_wallet_from_id: create(:wallet, currency: currency1).id,
          fund_wallet_to_id:   create(:wallet, currency: currency2).id,
          amount:              100.0
        }
      }
    end

    exchange_operation = ExchangeOperation.last

    assert_equal fin_manager.id, exchange_operation.user_id
    assert_equal 100.0, exchange_operation.amount
    assert_redirected_to admin_exchange_operation_path(exchange_operation)
  end
end
