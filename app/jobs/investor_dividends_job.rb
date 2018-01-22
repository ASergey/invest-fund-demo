class InvestorDividendsJob < ApplicationJob
  queue_as :balance_report_queue

  def perform(investor_id)
    Services::Reports::InvestorMonthlyReportBuilder.new(investor_id).call
  end
end
