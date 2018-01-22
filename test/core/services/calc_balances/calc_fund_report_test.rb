require 'test_helper'

class CalcFundReportTest < ActiveSupport::TestCase
  setup do
    @btc = create(:currency_btc)
  end

  test 'build since date without balance' do
    assert_nil Services::CalcBalances::CalcFundReport.build_since_date(Date.current)
    assert_nil Services::CalcBalances::CalcFundReport.build_since_date(1.day.ago.to_date)

    assert_no_difference 'FundBalanceReport.count' do
      Services::CalcBalances::CalcFundReport.build_since_date(5.days.ago.to_date)
    end
  end

  test 'build since date with balance' do
    create(:fund_balance, currency: @btc)
    assert_difference('FundBalanceReport.count', 10) do
      Services::CalcBalances::CalcFundReport.build_since_date(10.days.ago.to_date)
    end
  end

  test 'build sicne date with existing reports' do
    create(:fund_balance, currency: @btc)
    create(
      :fund_balance_report,
      amount: 1.0,
      currency: @btc,
      report_date: 7.days.ago.to_date
    )
    create(
      :fund_balance_report,
      amount: 2.0,
      currency: @btc,
      report_date: 4.days.ago.to_date
    )

    assert_difference('FundBalanceReport.count', 8) do
      Services::CalcBalances::CalcFundReport.build_since_date(10.days.ago.to_date)
    end

    assert_equal([], FundBalanceReport.by_report_date(11.days.ago.to_date).by_currency(@btc.id))
    reports = FundBalanceReport.by_currency(@btc).later_than(10.days.ago.to_date)
    reports.each do |report|
      assert_equal 0.0, report.amount if report.report_date < 7.days.ago.to_date
      assert_equal 1.0, report.amount if (7.days.ago.to_date..5.days.ago.to_date).cover?(report.report_date)
      assert_equal 2.0, report.amount if report.report_date >= 4.days.ago.to_date
    end
  end

  test 'no any report is present: investor investment' do
    f_balance = create(:fund_balance, amount: 20.0, currency: @btc)

    assert_difference('FundBalanceReport.count', 5) do
      create(
        :fund_operation,
        :done,
        investor: create(:user_investor),
        amount: 5.0,
        currency: @btc,
        operation_date: 5.days.ago.to_date
      )
    end

    reports = FundBalanceReport.by_currency(@btc).later_than(5.days.ago.to_date)
    reports.each do |report|
      assert_equal 5.0, report.amount
    end

    f_balance.reload
    assert_equal 25.0, f_balance.amount
  end

  test 'report present: investor investment undone' do
    create(:fund_balance, currency: @btc)
    create(
      :fund_balance_report,
      amount: 2.0,
      currency: @btc,
      report_date: 4.days.ago.to_date
    )
    done_operation = create(
      :fund_operation,
      :done,
      investor: create(:user_investor),
      amount: 5.0,
      currency: @btc,
      operation_date: 4.days.ago.to_date
    )

    assert_no_difference('FundBalanceReport.count') do
      done_operation.update(status: FundOperation::STATUS_CANCELED)
    end

    reports = FundBalanceReport.by_currency(@btc).later_than(4.days.ago.to_date)
    reports.each do |report|
      assert_equal 2.0, report.amount
    end
  end

  test 'report present: instrument payout' do
    instrument = create(:instrument)
    create(:fund_balance, currency: @btc)
    create(:instrument_balance, instrument: instrument, currency: @btc, amount: 10.0)
    create(
      :fund_balance_report,
      amount: 2.0,
      currency: @btc,
      report_date: 4.days.ago.to_date
    )

    operation = create(
      :operation_instrument_payout,
      :done,
      instrument: instrument,
      amount: 5.0,
      currency: @btc,
      operation_date: 5.days.ago.to_date
    )

    reports = FundBalanceReport.by_currency(@btc).later_than(5.days.ago.to_date)
    reports.each do |report|
      assert_equal 5.0, report.amount if report.report_date < 4.days.ago.to_date
      assert_equal 7.0, report.amount if report.report_date >= 4.days.ago.to_date
    end
  end

  test 'report present: instrument payout undone' do
    instrument = create(:instrument)
    create(:fund_balance, currency: @btc)
    create(:instrument_balance, instrument: instrument, currency: @btc, amount: 10.0)
    create(
      :fund_balance_report,
      amount: 2.0,
      currency: @btc,
      report_date: 4.days.ago.to_date
    )
    operation = create(
      :operation_instrument_payout,
      :done,
      instrument: instrument,
      amount: 5.0,
      currency: @btc,
      operation_date: 5.days.ago.to_date
    )

    assert_no_difference('FundBalanceReport.count') do
      operation.update(status: FundOperation::STATUS_CANCELED)
    end

    reports = FundBalanceReport.by_currency(@btc).later_than(5.days.ago.to_date)
    reports.each do |report|
      assert_equal 0.0, report.amount if report.report_date < 4.days.ago.to_date
      assert_equal 2.0, report.amount if report.report_date >= 4.days.ago.to_date
    end
  end
end
