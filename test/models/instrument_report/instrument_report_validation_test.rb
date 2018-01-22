require 'test_helper'

class InstrumentReportValidationTest < ActiveSupport::TestCase
  test 'unique instrument currency per day' do
    instrument_1 = create(:instrument)
    instrument_2 = create(:instrument)
    currency_1   = create(:currency)
    currency_2   = create(:currency)

    report_1 = build(:instrument_report, instrument: instrument_1, currency: currency_1, report_date: 1.day.ago)
    report_2 = build(:instrument_report, instrument: instrument_2, currency: currency_2, report_date: 1.day.ago)
    report_3 = build(:instrument_report, instrument: instrument_1, currency: currency_1, report_date: 2.days.ago)
    report_4 = build(:instrument_report, instrument: instrument_2, currency: currency_2, report_date: 2.days.ago)

    assert report_1.save
    assert report_2.save
    assert report_3.save
    assert report_4.save
  end

  test 'not unique instrument currency per day' do
    instrument_1 = create(:instrument)
    instrument_2 = create(:instrument)
    currency_1   = create(:currency)
    currency_2   = create(:currency)

    report_1 = build(:instrument_report, instrument: instrument_1, currency: currency_1)
    report_2 = build(:instrument_report, instrument: instrument_2, currency: currency_2)
    report_3 = build(:instrument_report, instrument: instrument_1, currency: currency_1)
    report_4 = build(:instrument_report, instrument: instrument_2, currency: currency_2)

    assert report_1.save
    assert report_2.save
    assert_not report_3.save
    assert_equal 'has already been taken', report_3.errors[:currency].first
    assert_not report_4.save
    assert_equal 'has already been taken', report_4.errors[:currency].first
  end
end
