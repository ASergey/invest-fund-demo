require 'test_helper'

class InvestorReportJobTest < ActiveJob::TestCase
  include ActiveJob::TestHelper

  setup do
    @investor1   = create(:user_investor)
    @investor2   = create(:user_investor)
    @usd         = create(:currency_usd)
    @report_data = {
      user:           @investor1,
      amount:         8000.0,
      daily_revenue:  0.49,
      capitalization: 1000.0,
      daily_profit:   100.0,
      currency:       @usd,
      report_date:    1.day.ago.to_date
    }
  end

  test 'direct run job test' do
    investor_report_service = mock('investor_report_builder')
    investor_report_service.expects(:normalize_revenue_share).twice.with(0.49 + 0.49)
    investor_report_service.expects(:call).twice.with(1.day.ago.to_date).returns(investor_report_service)
    investor_report_service.expects(:report_data).at_least(3).returns(@report_data)

    Services::Reports::InvestorReportBuilder.expects(:new).with(@investor1.id).returns(investor_report_service)
    Services::Reports::InvestorReportBuilder.expects(:new).with(@investor2.id).returns(investor_report_service)

    InvestorReport.expects(:by_date_report).with(@investor1.id, 1.day.ago.to_date).twice
    assert_difference('InvestorReport.count', 1) do # due to the same investor_id in report_data
      assert_raises(ActiveRecord::RecordInvalid) do
        InvestorReportJob.perform_now
      end
    end

    assert_enqueued_jobs 0
  end

  test 'direct run job test report exception' do
    Services::Reports::InvestorReportBuilder.any_instance.expects(:report_data).at_least(3).returns(
      user:   @investor1,
      amount: 8000.0,
      daily_revenue:  0.5
    )
    assert_raises(ActiveRecord::RecordInvalid) do
      InvestorReportJob.perform_now
    end

    assert_enqueued_jobs 0
  end

  test 'direct run job test last day of month' do
    report_date = 1.month.ago.to_date.end_of_month
    investor_report_service1 = mock('investor_report_builder_1')
    investor_report_service2 = mock('investor_report_builder_2')

    create(:investor_report, user: @investor1, report_date: report_date, currency: @usd)

    Services::Reports::InvestorReportBuilder.expects(:new).with(@investor1.id).returns(investor_report_service1)
    Services::Reports::InvestorReportBuilder.expects(:new).with(@investor2.id).returns(investor_report_service2)
    Services::Reports::InvestorReportBuilder.any_instance.expects(:normalize_revenue_share).never

    investor_report_service1.stubs(:call).with(report_date).returns(investor_report_service1)
    investor_report_service2.stubs(:call).with(report_date).returns(investor_report_service2)

    report_data1 = @report_data.merge(
      daily_revenue: 0.5,
      report_date: report_date
    )
    investor_report_service1.expects(:report_data).twice.returns(report_data1)
    investor_report_service2.expects(:report_data).twice.returns(@report_data.merge(
      user: @investor2,
      daily_revenue: 0.5,
      report_date: report_date
    ))

    assert_difference('InvestorReport.count', 1) do
      assert_enqueued_with(job: InvestorDividendsJob) do
        InvestorReportJob.perform_now(report_date)
      end
      assert_enqueued_jobs 2
    end
  end

  test 'direct rub job test: time travel to last month' do
    Time.zone = 'UTC'
    travel_to Time.zone.local(2017, 10, 1, 0, 13, 0)

    investor_report_service = mock('investor_report_builder')
    investor_report_service.expects(:normalize_revenue_share).twice.with(0.49 + 0.49)
    investor_report_service.expects(:call).twice.with(1.day.ago.to_date).returns(investor_report_service)
    investor_report_service.expects(:report_data).times(4).returns(@report_data.merge(report_date: 1.day.ago.to_date))

    Services::Reports::InvestorReportBuilder.expects(:new).with(@investor1.id).returns(investor_report_service)
    Services::Reports::InvestorReportBuilder.expects(:new).with(@investor2.id).returns(investor_report_service)

    assert_difference('InvestorReport.count', 1) do
      assert_enqueued_with(job: InvestorDividendsJob) do
        InvestorReportJob.perform_now
      end
      assert_enqueued_jobs 2
    end

    travel_back
  end
end
