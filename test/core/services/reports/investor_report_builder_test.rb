require 'test_helper'

class InvestorReportBuilderTest < ActiveSupport::TestCase
  setup do
    @usd         = create(:currency_usd, default: true)
    @report_date = 1.day.ago.to_date
    @investor    = create(:user_investor)
    @builder     = Services::Reports::InvestorReportBuilder.new(@investor.id)
  end

  test 'user not found' do
    assert_raises(ActiveRecord::RecordNotFound) do
      Services::Reports::InvestorReportBuilder.new(0)
    end
  end

  test 'user to find is not investor' do
    assert_raises(ActiveRecord::RecordNotFound) do
      Services::Reports::InvestorReportBuilder.new(create(:user).id)
    end
  end

  test 'report nil data response' do
    report_data_before_call = {
      user:           @investor,
      amount:         nil,
      daily_revenue:  nil,
      capitalization: nil,
      daily_profit:   nil,
      currency:       @usd,
      report_date:    nil
    }

    assert_equal report_data_before_call, @builder.report_data
  end

  test 'report data response' do
    FundOperation.expects(:investor_total_invested).with(@investor.id, @report_date).returns(100_000.00)
    Services::Reports::InvestorReportBuilder.any_instance.expects(:calc_daily_revenue)
                                            .with(@report_date).returns(0.55)
    Services::Reports::InvestorReportBuilder.any_instance.expects(:calc_capitalization)
                                            .with(@report_date).returns(150_000.00)
    Services::Reports::InvestorReportBuilder.any_instance.expects(:calc_daily_profit)
                                            .with(150_000.00).returns(10_000.00)

    report_data_after_call = {
      user:           @investor,
      amount:         100_000.00,
      daily_revenue:  0.55,
      capitalization: 150_000.00,
      daily_profit:   10_000.0,
      currency:       @usd,
      report_date:    @report_date
    }

    @builder.call
    assert_equal report_data_after_call, @builder.report_data
  end

  test 'normalize revenue share' do
    builder = Services::Reports::InvestorReportBuilder.new(@investor.id)
    builder.date          = 1.day.ago.to_date
    builder.daily_revenue = 0.49
    builder.expects(:calc_capitalization).with(builder.date).returns(150_000.00)
    builder.expects(:calc_daily_profit).with(150_000.00)

    assert_equal 0.5, builder.normalize_revenue_share(0.49 + builder.daily_revenue)
  end

  test 'capitalization before report date calculation (calc_cap_before)' do
    assert_equal 0.0, @builder.send(:calc_cap_before, @report_date)

    FundOperation.stubs(:investor_investment_before?).with(@investor.id, @report_date).returns(true)
    assert_equal 0.0, @builder.send(:calc_cap_before, @report_date)

    @builder.investor_total = 100_000.0
    assert_equal 100_000.0, @builder.send(:calc_cap_before, @report_date)

    InvestorReport.expects(:capitalization_before_date).with(@investor.id, @report_date).returns(140_000.0)
    assert_equal 140_000.0, @builder.send(:calc_cap_before, @report_date)
  end

  test 'calculate daily revenue' do
    assert_equal 0.0, @builder.send(:calc_daily_revenue, @report_date)

    FundBalance.expects(:total_capitalization).returns(1_100_000.0)
    assert_equal 0.0, @builder.send(:calc_daily_revenue, @report_date)

    FundBalance.expects(:total_capitalization).returns(-1_100_000.0)
    @builder.investor_total = 100_000.0
    assert_equal 0.0, @builder.send(:calc_daily_revenue, @report_date)

    FundBalance.expects(:total_capitalization).returns(1_200_000.0)
    assert_equal 100_000.0 / 1_200_000.0, @builder.send(:calc_daily_revenue, @report_date)

    FundReport.stubs(:capitalization_before_date).with(@report_date).returns(1_000_000.0)
    assert_equal 0.0, @builder.send(:calc_daily_revenue, @report_date)

    @builder.cap_before = 120_000.0
    assert_equal 120_000.0 / 1_000_000.0, @builder.send(:calc_daily_revenue, @report_date)
  end

  test 'calculate capitalization' do
    assert_equal 0.0, @builder.send(:calc_capitalization, @report_date)

    @builder.daily_revenue = 0.5
    assert_equal 0.0, @builder.send(:calc_capitalization, @report_date)

    FundBalance.expects(:total_capitalization).returns(1_000_000.0)
    assert_equal 1_000_000.0 * 0.5, @builder.send(:calc_capitalization, @report_date)

    FundReport.expects(:capitalization_by_date).with(2.days.ago.to_date).returns(1_200_000.0)
    assert_equal 1_200_000.0 * 0.5, @builder.send(:calc_capitalization, 2.days.ago.to_date)
  end

  test 'calculate daily profit' do
    assert_equal 0.0, @builder.send(:calc_daily_profit, 200_000.0)

    @builder.cap_before = 190_000.0
    assert_equal 200_000.0 - 190_000.0, @builder.send(:calc_daily_profit, 200_000.0)
  end
end
