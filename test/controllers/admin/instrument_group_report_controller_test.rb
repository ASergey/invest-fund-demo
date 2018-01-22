require 'test_helper'

class Admin::InstrumentGroupReportsControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers
  include ApplicationHelper

  setup do
    @group1 = create(:instrument_group)
    @group2 = create(:instrument_group)
    usd     = create(:currency_usd)
    instrument  = create(:instrument, instrument_group: @group1)
    instrument2 = create(:instrument, instrument_group: @group1)
    instrument3 = create(:instrument, instrument_group: @group2)
    @report1    = create(:instrument_report, instrument: instrument, currency: usd)
    @report2    = create(:instrument_report, instrument: instrument2, currency: usd)
    @report3    = create(:instrument_report, instrument: instrument3, currency: usd)
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

  test 'group reports list' do
    sign_in(create(:user_manager))

    get :index
    assert_response :success
    assert_includes @response.body, @group1.name
    assert_includes @response.body, @group2.name
    assert_includes @response.body, @report1.report_date.to_formatted_s(:long)
    assert_includes @response.body, number_format(@report1.amount + @report2.amount)
    assert_includes @response.body, number_format(@report3.amount)
  end

  test 'group reports list with filter' do
    sign_in(create(:user_manager))

    get :index, params: { q: { instrument_instrument_group_id_eq: @group1.id } }
    assert_response :success

    assert_includes @response.body, @group1.name
    assert_includes @response.body, @report1.report_date.to_formatted_s(:long)
    assert_includes @response.body, number_format(@report1.amount + @report2.amount)
    assert_not_includes @response.body, number_format(@report3.amount)
  end
end
