require 'test_helper'

class InstrumentsBalanceReportJobTest < ActiveJob::TestCase
  include ActiveJob::TestHelper

  test 'direct run job test: no instrument' do
    assert_raises(ActiveRecord::RecordNotFound) do
      assert_nil InstrumentsBalanceReportJob.perform_now(1)
    end
  end

  test 'direct run job test: no balance' do
    instrument = create(:instrument)

    assert_no_difference('InstrumentReport.count') do
      assert_nil InstrumentsBalanceReportJob.perform_now(instrument.id)
    end
  end

  test 'direct run job test' do
    balance1      = create(:instrument_balance)
    balance2      = create(:instrument_balance)
    ants7_balance = create(:instrument_hash_balance, :hashnest_ants7, instrument_balance: balance2)

    assert_difference('InstrumentReport.count', 1) do
      InstrumentsBalanceReportJob.perform_now(balance1.instrument.id)
    end

    assert_difference('InstrumentReport.count', 1) do
      InstrumentsBalanceReportJob.perform_now(balance2.instrument.id)
    end

    last_day_report1 = InstrumentReport.last_day_report(balance1.currency_id, balance1.instrument_id)
    last_day_report2 = InstrumentReport.last_day_report(balance2.currency_id, balance2.instrument_id)

    assert_equal balance1.amount, last_day_report1.amount
    assert_equal 1.day.ago.to_date, last_day_report1.report_date

    assert_equal balance2.amount, last_day_report2.amount
    assert_equal 1.day.ago.to_date, last_day_report2.report_date

    assert_empty last_day_report1.instrument_hash_reports
    assert_not_empty last_day_report2.instrument_hash_reports
    assert last_day_report2.instrument_hash_reports.any? { |h|
      h[:hash_amount] == ants7_balance.hash_amount && h[:hash_code] == ants7_balance.hash_code
    }
  end

  test 'direct run job test: last day report present' do
    balance = create(:instrument_balance, amount: 1_500.0)
    report  = create(:instrument_report, instrument: balance.instrument, currency: balance.currency)
    last_day_report = InstrumentReport.last_day_report(balance.currency_id, balance.instrument_id)

    assert_equal report.amount, last_day_report.amount
    assert_no_difference('InstrumentReport.count') do
      InstrumentsBalanceReportJob.perform_now(balance.instrument.id)
    end

    last_day_report = InstrumentReport.last_day_report(balance.currency_id, balance.instrument_id)
    assert_equal balance.amount, last_day_report.amount
  end
end
