require 'test_helper'

class Admin::InvestorReportsControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  setup do
    @investor = create(:user_investor)
    @i_report = create(:investor_report, user: @investor)
  end

  test 'unauthorized' do
    get :index, params: { user_id: @investor.id }
    assert_response :redirect
  end

  test 'no role' do
    sign_in(create(:user))
    get :index, params: { user_id: @investor.id }
    assert_response :redirect
  end

  test 'reports list' do
    sign_in(create(:user_manager))

    get :index, params: { user_id: @investor.id }
    assert_response :success
    assert_includes @response.body, @investor.name
    assert_includes @response.body, @i_report.report_date.to_formatted_s(:long)
  end

  test 'show report for date' do
    sign_in(create(:user_manager))
    get :show, params: { user_id: @investor.id, id: @i_report.id }

    assert_response :success
    assert_includes @response.body, @investor.name
    assert_includes @response.body, @i_report.report_date.to_formatted_s(:long)
  end
end
