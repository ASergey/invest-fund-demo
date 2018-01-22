require 'test_helper'

class InvestorReportTest < ActiveSupport::TestCase
  setup do
    @investor = create(:user_investor)
    create(:investor_report, report_date: '2017-09-30')
    create(:investor_report, user: @investor, report_date: '2017-09-30')
    create(:investor_report, user: @investor, report_date: '2017-09-27')
  end

  test 'capitalization before date' do
    assert_nil InvestorReport.capitalization_before_date(@investor.id, '2017-09-30')

    report = create(:investor_report, user: @investor, report_date: '2017-09-29')
    assert_equal report.capitalization, InvestorReport.capitalization_before_date(@investor.id, '2017-09-30')
  end

  test 'today report' do
    assert_nil InvestorReport.today_report(@investor.id)

    report = create(:investor_report, user: @investor, report_date: Date.current)
    assert_equal report, InvestorReport.today_report(@investor.id)
  end

  test 'by date report' do
    assert_nil InvestorReport.by_date_report(create(:user_investor).id, '2017-09-27')
    assert_nil InvestorReport.by_date_report(@investor.id, '2017-09-24')
    assert InvestorReport.by_date_report(@investor.id, '2017-09-30')
  end

  test 'profit before date' do
    assert_nil InvestorReport.profit_before_date(create(:user_investor).id, '2017-09-29')
    assert_nil InvestorReport.profit_before_date(@investor.id, '2017-09-24')

    report = create(:investor_report, user: @investor, report_date: '2017-09-29')
    assert_equal report.daily_profit, InvestorReport.profit_before_date(@investor.id, '2017-09-30')
  end

  test 'monthly profit' do
    assert_equal 0.0, InvestorReport.monthly_profit(create(:user_investor).id, '2017-09-29')
    assert_equal 0.0, InvestorReport.monthly_profit(@investor.id, '2017-08-30')
    assert_equal 20.0, InvestorReport.monthly_profit(@investor.id, '2017-09-24')
    assert_equal 20.0, InvestorReport.monthly_profit(@investor.id, '2017-09-30')
  end
end
