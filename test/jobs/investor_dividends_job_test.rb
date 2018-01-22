require 'test_helper'

class InvestorDividendsJobTest < ActiveJob::TestCase
  include ActiveJob::TestHelper

  test 'direct run job test' do
    investor1 = create(:user_investor)

    builder = mock('investor_monthly_report_builder')
    builder.stubs(:call).returns(true)
    Services::Reports::InvestorMonthlyReportBuilder.stubs(:new).with(investor1.id).returns(builder)

    InvestorDividendsJob.perform_now(investor1.id)
  end
end
