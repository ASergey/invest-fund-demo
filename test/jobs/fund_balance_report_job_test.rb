require 'test_helper'

class FundBalanceReportJobTest < ActiveJob::TestCase
  include ActiveJob::TestHelper

  setup do
    @usd_balance = create(:fund_balance, :usd)
    @btc_balance = create(:fund_balance, :btc)
    @ltc_balance = create(:fund_balance, :ltc)
  end

  test 'direct run job test: create new reports' do
    assert_difference('FundBalanceReport.count', 3) do
      FundBalanceReportJob.perform_now
    end

    assert_equal @usd_balance.amount, FundBalanceReport.last_day_report(@usd_balance.currency_id).amount
    assert_equal @btc_balance.amount, FundBalanceReport.last_day_report(@btc_balance.currency_id).amount
    assert_equal @ltc_balance.amount, FundBalanceReport.last_day_report(@ltc_balance.currency_id).amount
  end

  test 'direct run job test: update existing reports' do
    create(:fund_balance_report, currency: @usd_balance.currency, amount: 10_000.0, report_date: 1.day.ago.to_date)
    create(:fund_balance_report, currency: @btc_balance.currency, amount: 1.0, report_date: 1.day.ago.to_date)
    create(:fund_balance_report, currency: @ltc_balance.currency, amount: 10.0, report_date: 1.day.ago.to_date)

    assert_difference('FundBalanceReport.count', 0) do
      FundBalanceReportJob.perform_now
    end

    assert_equal @usd_balance.amount, FundBalanceReport.last_day_report(@usd_balance.currency_id).amount
    assert_equal @btc_balance.amount, FundBalanceReport.last_day_report(@btc_balance.currency_id).amount
    assert_equal @ltc_balance.amount, FundBalanceReport.last_day_report(@ltc_balance.currency_id).amount
  end

  test 'direct run job test: validation error' do
    FundBalance.any_instance.stubs(:amount).returns(nil)

    assert_difference('FundBalanceReport.count', 0) do
      assert_raises(ActiveRecord::RecordInvalid) do
        FundBalanceReportJob.perform_now
      end
    end
  end
end
