require 'test_helper'

class Admin::InstrumentBalancesControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  setup do
    @instrument = create(:instrument)
    @i_balance1 = create(:instrument_balance, instrument: @instrument)
    @i_balance2 = create(:instrument_balance, instrument: @instrument)
  end

  test 'unauthorized' do
    get :index, params: { instrument_id: @instrument.id }
    assert_response :redirect
  end

  test 'no role' do
    sign_in(create(:user))
    get :index, params: { instrument_id: @instrument.id }
    assert_response :redirect
  end

  test 'balances list' do
    sign_in(create(:user_manager))

    get :index, params: { instrument_id: @instrument.id }
    assert_response :success
  end

  test 'new instrument balance failed' do
    sign_in(create(:user_manager))

    get :new, params: { instrument_id: @instrument.id }
    assert_response :redirect
  end

  test 'new instrument balance' do
    sign_in(create(:user_fin_manager))

    get :new, params: { instrument_id: @instrument.id }
    assert_response :success
  end

  test 'edit instrument balance' do
    sign_in(create(:user_fin_manager))

    get :edit, params: { instrument_id: @instrument.id, id: @i_balance1.id }
    assert_response :success
  end

  test 'create instrument balance success' do
    sign_in(create(:user_fin_manager))
    currency = create(:currency)

    assert_difference('InstrumentBalance.count') do
      post :create, params: {
        instrument_id: @instrument.id,
        instrument_balance: {
          amount: 10.0,
          currency_id: currency.id
        }
      }
    end

    assert_redirected_to admin_instrument_instrument_balances_path(@instrument)
  end

  test 'create instrument balance failed' do
    sign_in(create(:user_fin_manager))

    assert_no_difference('InstrumentBalance.count') do
      post :create, params: {
        instrument_id: @instrument.id,
        instrument_balance: { amount: 10.0 }
      }
    end

    assert_response :success
  end
end
