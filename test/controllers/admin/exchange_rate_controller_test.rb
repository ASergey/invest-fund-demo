require 'test_helper'

class Admin::ExchangeRatesControllerTest < ActionController::TestCase
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

  test 'rates list' do
    sign_in(create(:user_manager))
    get :index
    assert_response :success
  end

  test 'no other actions excepting index one' do
    sign_in(create(:user_manager))

    assert_raises(ActionController::UrlGenerationError) do
      get :new
    end
  end

  test 'fetch_rate success' do
    currency1 = create(:currency)
    currency2 = create(:currency)
    create(:exchange_rate, from_currency: currency1, to_currency: currency2)
    sign_in(create(:user_manager))

    get :fetch_rate, params: {
      currency_id: currency1.id,
      to_currency_id: currency2.id
    }, xhr: true

    response_body = JSON.parse(@response.body)
    assert_response :success
    assert_not_empty response_body['rate']
    assert_equal currency1.id, response_body['rate']['currency_id']
    assert_equal currency2.id, response_body['rate']['to_currency_id']
  end

  test 'fetch_rate fail: empty params' do
    sign_in(create(:user_manager))
    get :fetch_rate, xhr: true

    response_body = JSON.parse(@response.body)
    assert_response :unprocessable_entity
    assert_not_empty response_body
  end

  test 'fetch_rate fail: wrong params' do
    sign_in(create(:user_manager))
    get :fetch_rate, params: { currency_id: create(:currency).id }, xhr: true

    response_body = JSON.parse(@response.body)
    assert_response :unprocessable_entity
    assert_not_empty response_body

    get :fetch_rate, params: { to_currency_id: create(:currency).id }, xhr: true

    response_body = JSON.parse(@response.body)
    assert_response :unprocessable_entity
    assert_not_empty response_body
  end

  test 'fetch_rate not found' do
    sign_in(create(:user_manager))

    get :fetch_rate, params: {
      currency_id: create(:currency).id,
      to_currency_id: create(:currency).id
    }, xhr: true

    response_body = JSON.parse(@response.body)
    assert_response :unprocessable_entity
    assert_not_empty response_body
  end
end
