require 'test_helper'

class FundReportsTest < ActiveSupport::TestCase
  test 'capitalization before date' do
    day_ago_report = create(:fund_report, :usd)
    assert_equal day_ago_report.capitalization, FundReport.capitalization_before_date(Date.current)
    assert_nil FundReport.capitalization_before_date(1.day.ago)
  end

  test 'capitalization by date' do
    day_ago_report = create(:fund_report, :usd)
    assert_equal day_ago_report.capitalization, FundReport.capitalization_by_date(1.day.ago)
    assert_nil FundReport.capitalization_before_date(2.days.ago)
  end
end
