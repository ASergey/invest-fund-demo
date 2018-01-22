require 'test_helper'

class FundBalanceDateReportJobTest < ActiveJob::TestCase
  include ActiveJob::TestHelper

  test 'direct run job test' do
    Services::CalcBalances::CalcFundReport.expects(:build_since_date).with(2.days.ago.to_date)
    FundBalanceDateReportJob.perform_now(2.days.ago.to_date)
  end
end
