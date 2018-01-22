require 'test_helper'

class Admin::FundReportsControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers
  include ApplicationHelper

  setup do
    @report = create(:fund_report)
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

  test 'reports list' do
    sign_in(create(:user_manager))

    get :index
    assert_response :success
    assert_includes @response.body, number_format(@report.total_invested)
    assert_includes @response.body, number_format(@report.capitalization)
  end

  test 'show report' do
    sign_in(create(:user_manager))

    get :show, params: { id: @report.id }
    assert_response :success
    assert_includes @response.body, number_format(@report.total_invested)
    assert_includes @response.body, number_format(@report.capitalization)
  end
end
