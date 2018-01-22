require 'test_helper'

class Admin::FundBalancesControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  setup do
    @f_balance = create(:fund_balance)
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

  test 'raises template error without default currency and rates' do
    sign_in(create(:user_manager))
    assert_raises('ActionView::Template::Error') do
      get :index
    end

    usd = create(:currency_usd)
    assert_raises('ActionView::Template::Error') do
      get :index
    end    
  end

  test 'balances list' do
    sign_in(create(:user_manager))
    usd = create(:currency_usd)
    create(:exchange_rate, from_currency: @f_balance.currency, to_currency: usd, rate: 0.5)

    get :index
    assert_response :success
  end
end
