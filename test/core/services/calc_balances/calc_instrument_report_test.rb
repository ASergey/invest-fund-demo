require 'test_helper'

class CalcInstrumentReportTest < ActiveSupport::TestCase
  setup do
    @btc        = create(:currency_btc)
    @instrument = create(:instrument)
    @i_balance  = create(:instrument_balance, instrument: @instrument, currency: @btc, amount: 10.0)
  end

  test 'build since date without balance' do
    assert_nil Services::CalcBalances::CalcInstrumentReport.build_since_date(Date.current, create(:instrument).id)
    assert_nil Services::CalcBalances::CalcInstrumentReport.build_since_date(1.day.ago.to_date, nil)

    assert_no_difference 'InstrumentReport.count' do
      Services::CalcBalances::CalcInstrumentReport.build_since_date(5.days.ago.to_date, create(:instrument).id)
    end
  end

  test 'build since date with 0.0 balance' do
    assert_difference('InstrumentReport.count', 10) do
      Services::CalcBalances::CalcInstrumentReport.build_since_date(10.days.ago.to_date, @i_balance.instrument_id)
    end
  end

  test 'build since date with existing reports' do
    create(
      :instrument_report,
      instrument: @instrument,
      amount: 1.0,
      currency: @btc,
      report_date: 7.days.ago.to_date
    )
    create(
      :instrument_report,
      instrument: @instrument,
      amount: 2.0,
      currency: @btc,
      report_date: 4.days.ago.to_date
    )

    assert_difference('InstrumentReport.count', 8) do
      Services::CalcBalances::CalcInstrumentReport.build_since_date(10.days.ago.to_date, @i_balance.instrument_id)
    end

    assert_equal(
      [],
      InstrumentReport.by_instrument(@instrument.id).by_report_date(11.days.ago.to_date).by_currency(@btc.id)
    )
    reports = InstrumentReport.by_instrument(@instrument.id).by_currency(@btc).later_than(10.days.ago.to_date)
    reports.each do |report|
      assert_equal 0.0, report.amount if report.report_date < 7.days.ago.to_date
      assert_equal 1.0, report.amount if (7.days.ago.to_date..5.days.ago.to_date).cover?(report.report_date)
      assert_equal 2.0, report.amount if report.report_date >= 4.days.ago.to_date
    end
  end

  test 'no any report is present: instrument investment' do
    currency = create(:currency)
    create(:fund_balance, amount: 20.0, currency: @btc)
    create(:instrument_balance, instrument: @instrument, currency: currency)

    assert_difference('InstrumentReport.count', 10) do
      create(
        :operation_instrument_investment,
        :done,
        instrument: @instrument,
        amount: 5.0,
        currency: @btc,
        operation_date: 5.days.ago.to_date
      )
    end

    reports = InstrumentReport.by_instrument(@instrument.id).by_currency(@btc).later_than(5.days.ago.to_date)
    reports.each do |report|
      assert_equal 5.0, report.amount
    end

    reports = InstrumentReport.by_instrument(@instrument.id).by_currency(currency).later_than(5.days.ago.to_date)
    reports.each do |report|
      assert_equal 0.0, report.amount
    end
  end

  test 'no any report is present: instrument payout' do
    currency     = create(:currency)
    fund_balance = create(:fund_balance, amount: 20.0, currency: @btc)
    create(:instrument_balance, instrument: @instrument, currency: currency)

    assert_difference('InstrumentReport.count', 10) do
      create(
        :operation_instrument_payout,
        :done,
        instrument: @instrument,
        amount: 2.0,
        currency: @btc,
        operation_date: 5.days.ago.to_date
      )
    end
    fund_balance.reload

    reports = InstrumentReport.by_instrument(@instrument.id).by_currency(@btc).later_than(5.days.ago.to_date)
    reports.each do |report|
      assert_equal(-2.0, report.amount)
    end

    reports = InstrumentReport.by_instrument(@instrument.id).by_currency(currency).later_than(5.days.ago.to_date)
    reports.each do |report|
      assert_equal 0.0, report.amount
    end

    assert_equal 20.0 + 2.0, fund_balance.amount
  end

  test 'report later is present' do
    currency      = create(:currency)
    amount_before = 20.0
    f_balance     = create(:fund_balance, amount: 20.0, currency: @btc)
    i_report      = create(
      :instrument_report,
      instrument: @instrument,
      amount: amount_before,
      currency: @btc,
      report_date: 2.days.ago.to_date
    )
    create(:instrument_balance, instrument: @instrument, currency: currency)

    assert_difference('InstrumentReport.count', 9) do
      create(
        :operation_instrument_investment,
        :done,
        instrument: @instrument,
        amount: 5.0,
        currency: @btc,
        operation_date: 5.days.ago.to_date
      )
    end

    i_report.reload
    f_balance.reload
    assert_equal 5.0 + amount_before, i_report.amount

    reports = InstrumentReport.by_instrument(@instrument.id).by_currency(@btc).later_than(5.days.ago.to_date)
    reports.each do |report|
      assert_equal 5.0, report.amount if report.report_date < i_report.report_date
      assert_equal 5.0 + amount_before, report.amount if report.report_date >= i_report.report_date
    end

    reports = InstrumentReport.by_instrument(@instrument.id).by_currency(currency).later_than(5.days.ago.to_date)
    reports.each do |report|
      assert_equal 0.0, report.amount
    end

    assert_equal 20.0 - 5.0, f_balance.amount
  end

  test 'operation date report exists' do
    currency      = create(:currency)
    amount_before = 20.0
    f_balance     = create(:fund_balance, amount: 20.0, currency: @btc)
    i_report      = create(
      :instrument_report,
      instrument: @instrument,
      amount: amount_before,
      currency: @btc,
      report_date: 5.days.ago.to_date
    )
    create(:instrument_balance, instrument: @instrument, currency: currency)

    assert_difference('InstrumentReport.count', 9) do
      create(
        :operation_instrument_investment,
        :done,
        instrument: @instrument,
        amount: 5.0,
        currency: @btc,
        operation_date: 5.days.ago.to_date
      )
    end

    i_report.reload
    f_balance.reload
    assert_equal 5.0 + amount_before, i_report.amount

    reports = InstrumentReport.by_instrument(@instrument.id).by_currency(@btc).later_than(5.days.ago.to_date)
    reports.each do |report|
      assert_equal 5.0, report.amount if report.report_date < i_report.report_date
      assert_equal 5.0 + amount_before, report.amount if report.report_date >= i_report.report_date
    end

    reports = InstrumentReport.by_instrument(@instrument.id).by_currency(currency).later_than(5.days.ago.to_date)
    reports.each do |report|
      assert_equal 0.0, report.amount
    end

    assert_equal 20.0 - 5.0, f_balance.amount
  end

  test 'report exists operation investment made undone' do
    amount_before = 20.0
    f_balance     = create(:fund_balance, amount: 20.0, currency: @btc)
    i_report      = create(
      :instrument_report,
      instrument: @instrument,
      amount: amount_before,
      currency: @btc,
      report_date: 5.days.ago.to_date
    )

    operation = create(
      :operation_instrument_investment,
      :done,
      instrument: @instrument,
      amount: 5.0,
      currency: @btc,
      operation_date: 5.days.ago.to_date
    )

    i_report.reload
    f_balance.reload
    assert_equal 5.0 + amount_before, i_report.amount
    assert_equal 20.0 - 5.0, f_balance.amount

    operation.update(status: FundOperation::STATUS_CANCELED)

    f_balance.reload

    reports = InstrumentReport.by_instrument(@instrument.id).by_currency(@btc).later_than(5.days.ago.to_date)
    reports.each do |report|
      assert_equal amount_before, report.amount
    end

    assert_equal 20.0, f_balance.amount
  end

  test 'report exists operation payout made undone' do
    amount_before = 20.0
    f_balance     = create(:fund_balance, amount: 20.0, currency: @btc)
    i_report      = create(
      :instrument_report,
      instrument: @instrument,
      amount: amount_before,
      currency: @btc,
      report_date: 5.days.ago.to_date
    )

    operation = create(
      :operation_instrument_payout,
      :done,
      instrument: @instrument,
      amount: 5.0,
      currency: @btc,
      operation_date: 5.days.ago.to_date
    )

    i_report.reload
    f_balance.reload
    assert_equal amount_before - 5.0, i_report.amount
    assert_equal 20.0 + 5.0, f_balance.amount

    operation.update(status: FundOperation::STATUS_CANCELED)

    f_balance.reload

    reports = InstrumentReport.by_instrument(@instrument.id).by_currency(@btc).later_than(5.days.ago.to_date)
    reports.each do |report|
      assert_equal amount_before, report.amount
    end

    assert_equal 20.0, f_balance.amount
  end
end
