require 'test_helper'

class Admin::FundOperationsControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  setup do
    @usd       = create(:currency_usd)
    @operation = create(:fund_operation, :done, currency: @usd)
  end

  test 'operations unauthorized' do
    get :index
    assert_response :redirect
  end

  test 'operations no role' do
    sign_in(create(:user))
    get :index
    assert_response :redirect
  end

  test 'manager should see operations list' do
    sign_in(create(:user_manager))
    get :index
    assert_response :success
    assert_includes @response.body, @operation.operation_date.to_formatted_s(:long)
  end

  test 'should open show operation page for manager' do
    sign_in(create(:user_manager))
    get :show, params: { id: @operation.id }

    assert_response :success
    assert_includes @response.body, @operation.operation_date.to_formatted_s(:long)
  end

  test 'should open new operation form: manager' do
    sign_in(create(:user_manager))
    get :new
    assert_response :success
  end

  test 'should open new operation form: fin-manager' do
    sign_in(create(:user_fin_manager))
    get :new
    assert_response :success
  end

  test 'should open edit for operation' do
    sign_in(create(:user_manager))

    get :edit, params: { id: @operation.id }
    assert_response :success
    assert_includes @response.body, @operation.operation_date.to_s
  end

  test 'should open edit for operation: fin manager' do
    sign_in(create(:user_manager))

    get :edit, params: { id: @operation.id }
    assert_response :success
    assert_includes @response.body, @operation.operation_date.to_s
  end

  test 'should create operation successfully' do
    investor = create(:user_investor)
    manager  = create(:user_manager)

    create(:kyc_document, user: investor)
    sign_in(manager)

    assert_difference('FundOperation.count') do
      post :create, params: {
        fund_operation: {
          investor_id:           investor.id,
          amount:                10.0,
          currency_id:           @usd.id,
          operation_type:        FundOperation::TYPE_INVESTMENT,
          status:                FundOperation::STATUS_PENDING,
          payment_resource_type: FundOperation::RESOURCE_TYPE_BANK_ACCOUNT,
          user_id:               manager.id,
          operation_date:        Date.current.to_s
        }
      }
    end
    fund_operation = FundOperation.last

    assert_equal investor.id, fund_operation.investor_id
    assert_equal 10.0, fund_operation.amount
    assert_equal manager.id, fund_operation.user_id
    assert_redirected_to admin_fund_operations_path
  end

  test 'should fail creating fund operation due to validation error' do
    sign_in(create(:user_manager))

    assert_no_difference('FundOperation.count') do
      post :create, params: {
        fund_operation: {
          investor_id: create(:user_investor).id,
          amount:      10.0
        }
      }
    end

    assert_response :success
  end

  test 'should not responde to operation delete' do
    assert_raises(ActionController::UrlGenerationError) do
      delete :destroy, params: { id: @operation.id }
    end
  end
end
