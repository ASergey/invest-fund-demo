class FundBalanceDateReportJob < ApplicationJob
  queue_as :balance_report_queue

  def perform(date)
    Services::CalcBalances::CalcFundReport.build_since_date(date)
  end
end
