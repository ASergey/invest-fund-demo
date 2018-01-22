require 'test_helper'
require 'rake'

class FundReportJobTest < ActiveJob::TestCase
  include ActiveJob::TestHelper

  setup do
    @usd = create(:currency_usd)
  end

  test 'direct run job test' do    
    FundBalanceReport.stubs(:total_capitalization).with(1.day.ago.to_date).returns(500000.0)
    FundOperation.stubs(:total_invested).with(1.day.ago.to_date).returns(100000.0)
    FundOperation.stubs(:daily_invested).with(1.day.ago.to_date).returns(1000.0)
    FundOperation.stubs(:daily_fees).with(1.day.ago.to_date).returns(100.0)

    assert_difference('FundReport.count', 1) do
      InvestorReportJob.expects(:perform_now).times(2)
      FundReportJob.perform_now
      FundReportJob.perform_now
    end

    date_report = FundReport.by_report_date(1.day.ago.to_date).first
    assert_equal 100000.0, date_report.total_invested
    assert_equal 500000.0, date_report.capitalization
    assert_equal 1000.0, date_report.daily_invested
    assert_equal 100.0, date_report.total_fees
    assert_equal @usd, date_report.currency
    assert_equal 1.day.ago.to_date, date_report.report_date
  end

  test 'direct run job: 5 days ago test' do
    report_date = 5.days.ago.to_date

    FundBalanceReport.stubs(:total_capitalization).times(5).returns(500000.0)
    FundOperation.stubs(:total_invested).times(5).returns(100000.0)
    FundOperation.stubs(:daily_invested).times(5).returns(1000.0)
    FundOperation.stubs(:daily_fees).times(5).returns(100.0)

    InvestorReportJob.stubs(:perform_now).times(5)
    assert_difference('FundReport.count', 5) do
      FundReportJob.perform_now(report_date)
    end
  end

  test 'fund_report task call' do
    Rails.application.load_tasks
    Rake::Task.define_task(:environment)

    FundReportJob.expects(:perform_later).with(1.day.ago.to_date.to_s)
    $stdout = File.new( '/dev/null', 'w' )
    Rake::Task["fund_report:fund_report"].invoke
    $stdout = STDOUT
    # FundReportJob.expects(:perform_later).with(5.days.ago.to_date.to_s)
    # Rake.application.invoke_task("fund_report:fund_report['#{5.days.ago.to_date}']")
  end
end
