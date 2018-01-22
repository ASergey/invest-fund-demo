require 'test_helper'

class Admin::InstrumentGroupsControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  setup do
    @group1 = create(:instrument_group)
    @group2 = create(:instrument_group)
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

  test 'index' do
    sign_in(create(:user_manager))

    get :index
    assert_response :success
  end

  test 'manager new' do
    sign_in(create(:user_manager))
    get :new
    assert_response :redirect
  end

  test 'manager edit' do
    sign_in(create(:user_manager))
    get :edit, params: { id: @group1.id }
    assert_response :redirect
  end

  test 'manager update' do
    sign_in(create(:user_manager))

    post :update, params: {
      id: @group2.id,
      instrument_group: {
        name: 'new name'
      }
    }

    assert_response :redirect
    @group2.reload
    assert_not_equal 'new name', @group2.name
  end

  test 'new' do
    sign_in(create(:user_fin_manager))
    get :new
    assert_response :success
  end

  test 'edit' do
    sign_in(create(:user_fin_manager))

    get :edit, params: { id: @group1.id }
    assert_response :success
    assert_includes @response.body, @group1.name
  end

  test 'update' do
    sign_in(create(:user_fin_manager))

    post :update, params: {
      id: @group2.id,
      instrument_group: {
        name: 'new name'
      }
    }

    assert_response :redirect
    @group2.reload
    assert_equal 'new name', @group2.name
  end
end
