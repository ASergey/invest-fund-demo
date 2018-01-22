require 'test_helper'

class Admin::InstrumentsControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  setup do
    @instrument = create(:instrument)
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

  test 'instruments list' do
    sign_in(create(:user_manager))

    get :index
    assert_response :success
    assert_includes @response.body, @instrument.name
  end

  test 'show' do
    sign_in(create(:user_manager))

    get :show, params: { id: @instrument.id }
    assert_response :success
    assert_includes @response.body, @instrument.name
  end

  test 'new instrument failed' do
    sign_in(create(:user_manager))

    get :new
    assert_response :redirect
  end

  test 'new instrument' do
    sign_in(create(:user_fin_manager))

    get :new
    assert_response :success
  end

  test 'edit instrument' do
    sign_in(create(:user_fin_manager))

    get :edit, params: { id: @instrument.id }
    assert_response :success
  end

  test 'create instrument success' do
    sign_in(create(:user_fin_manager))

    assert_difference('Instrument.count') do
      post :create, params: {
        instrument: {
          name: 'Test instrument',
          instrument_type: Instrument::INSTRUMENT_TYPE_DEFAULT
        }
      }
    end
    instrument = Instrument.last
    assert_redirected_to admin_instrument_path(instrument)
  end

  test 'create instrument failed' do
    sign_in(create(:user_fin_manager))

    assert_no_difference('Instrument.count') do
      post :create, params: {
        instrument: {
          instrument_type: Instrument::INSTRUMENT_TYPE_DEFAULT
        }
      }
    end

    assert_response :success
  end
end
