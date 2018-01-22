require 'test_helper'

class FundBalanceReportTest < ActiveSupport::TestCase
  setup do
    @usd = create(:currency_usd)
    @btc = create(:currency_btc)
    @ltc = create(:currency_ltc)

    (2.days.ago.to_date..1.day.ago.to_date).each do |date|
      create(:exchange_rate, rate: 5_000.0, created_at: date, from_currency: @btc, to_currency: @usd)
      create(:exchange_rate, rate: 80.0, created_at: date, from_currency: @ltc, to_currency: @usd)
      create(:fund_balance_report, currency: @usd, amount: 10_000.0, report_date: date)
      create(:fund_balance_report, currency: @btc, amount: 10.0, report_date: date)
      create(:fund_balance_report, currency: @ltc, amount: 100.0, report_date: date)
    end

    InstrumentReport.stubs(:total_capitalization).with(2.days.ago.to_date).returns(10_000.0)
    InstrumentReport.stubs(:total_capitalization).with(1.day.ago.to_date).returns(8_000.0)
    InstrumentReport.stubs(:total_capitalization).with(Date.current).returns(0.0)
  end

  test 'capitalization' do
    assert_equal 0.0, FundBalanceReport.capitalization(Date.current)

    assert_equal 10_000.0 + 5_000.0 * 10.0 + 80.0 * 100.0, FundBalanceReport.capitalization(1.day.ago.to_date)
    assert_equal 10_000.0 + 5_000.0 * 10.0 + 80.0 * 100.0, FundBalanceReport.capitalization(2.days.ago.to_date)
  end

  test 'total capitalization' do
    assert_equal 0.0, FundBalanceReport.total_capitalization(Date.current)
    assert_equal 10_000.0 + 5_000.0 * 10.0 + 80.0 * 100.0 + 8_000.0,
                 FundBalanceReport.total_capitalization(1.day.ago.to_date)
    assert_equal 10_000.0 + 5_000.0 * 10.0 + 80.0 * 100.0 + 10_000.0,
                 FundBalanceReport.total_capitalization(2.days.ago.to_date)
  end

  test 'today report' do
    assert_nil FundBalanceReport.today_report(@usd.id)
    assert_nil FundBalanceReport.today_report(@btc.id)
    assert_nil FundBalanceReport.today_report(@ltc.id)

    today_report = create(:fund_balance_report, currency: @usd, report_date: Date.current)
    assert_equal today_report, FundBalanceReport.today_report(@usd.id)
  end

  test 'last_day_report' do
    last_day_usd = FundBalanceReport.last_day_report(@usd.id)
    last_day_btc = FundBalanceReport.last_day_report(@btc.id)
    last_day_ltc = FundBalanceReport.last_day_report(@ltc.id)

    assert_equal 1.day.ago.to_date, last_day_usd.report_date
    assert_equal 1.day.ago.to_date, last_day_btc.report_date
    assert_equal 1.day.ago.to_date, last_day_ltc.report_date

    assert_equal 10_000.0, last_day_usd.amount
    assert_equal 10.0, last_day_btc.amount
    assert_equal 100.0, last_day_ltc.amount

    assert_nil FundBalanceReport.last_day_report(create(:currency).id)
  end
end
