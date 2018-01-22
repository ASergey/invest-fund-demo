require 'test_helper'

class InstrumentReportCapitalizationTest < ActiveSupport::TestCase
  test 'total_balance' do
    ico_report = create(:instrument_report, :usd)
    hashnest_report = create(:hashnest_btc_report)

    assert_equal ico_report.amount, ico_report.total_balance
    total_hashnest = hashnest_report.amount
    hashnest_report.instrument_hash_reports.each do |hash_report|
      total_hashnest += hash_report.hash_amount * hash_report.hash_rate
    end
    assert_equal total_hashnest, hashnest_report.total_balance
  end

  test 'total capitalization' do
    InstrumentReport.any_instance.stubs(:total_balance).returns(1000.0)
    report1 = create(:instrument_report, report_date: 2.days.ago)
    report2 = create(:instrument_report, report_date: 2.days.ago)

    assert_equal 0.0, InstrumentReport.total_capitalization(1.day.ago.to_date)
    assert_raises I18n.t('report.exchange_rate_error', currency: report1.currency.symbol) do
      InstrumentReport.total_capitalization(2.days.ago.to_date)
    end

    ExchangeRate.stubs(:convert_to_default)
                .with(1000.0, report1.currency, 2.days.ago.to_date).returns(5000.0)
    ExchangeRate.stubs(:convert_to_default)
                .with(1000.0, report1.currency, 1.day.ago.to_date).returns(6000.0)
    ExchangeRate.stubs(:convert_to_default)
                .with(1000.0, report2.currency, 2.days.ago.to_date).returns(2000.0)
    ExchangeRate.stubs(:convert_to_default)
                .with(1000.0, report2.currency, 1.day.ago.to_date).returns(3000.0)

    assert_equal 7000.0, InstrumentReport.total_capitalization(2.days.ago.to_date)
  end

  test 'last_day_report' do
    instrument     = create(:instrument)
    currency       = create(:currency)
    correct_report = create(:instrument_report, instrument: instrument, currency: currency)
    create(
      :instrument_report,
      instrument: instrument,
      currency: currency,
      report_date: 2.days.ago.to_date
    )
    create(
      :instrument_report,
      instrument: instrument,
      currency: currency,
      report_date: Date.current
    )

    assert_nil InstrumentReport.last_day_report(create(:currency).id, create(:instrument).id)
    assert_nil InstrumentReport.last_day_report(currency.id, create(:instrument).id)
    assert_nil InstrumentReport.last_day_report(create(:currency).id, instrument.id)
    assert_equal correct_report, InstrumentReport.last_day_report(currency.id, instrument.id)
  end

  test 'gruped daily reports' do
    group1      = create(:instrument_group)
    group2      = create(:instrument_group)
    currency1   = create(:currency)
    currency2   = create(:currency)
    instrument1 = create(:instrument, instrument_group: group1)
    instrument2 = create(:instrument, instrument_group: group1)
    instrument3 = create(:instrument, instrument_group: group2)
    instrument4 = create(:instrument, instrument_group: group2)

    create(:instrument_report, amount: 10.0, instrument: instrument1, currency: currency1)
    create(:instrument_report, amount: 20.0, instrument: instrument2, currency: currency1)
    create(:instrument_report, amount: 30.0, instrument: instrument3, currency: currency1)
    create(:instrument_report, amount: 40.0, instrument: instrument4, currency: currency2)

    InstrumentReport.grouped_daily_reports.each do |report|
      assert_equal 10.0 + 20.0, report.sum_amount if report.group_name == group1.name
      assert_equal 30.0, report.sum_amount if report.group_name == group2.name && report.currency_id == currency1.id
      assert_equal 40.0, report.sum_amount if report.group_name == group2.name && report.currency_id == currency2.id
      assert_equal currency1.symbol, report.symbol if report.currency_id == currency1.id
      assert_equal currency2.symbol, report.symbol if report.currency_id == currency2.id
      assert_equal currency1.symbol, report.symbol if report.group_name == group1.name
    end
  end
end
