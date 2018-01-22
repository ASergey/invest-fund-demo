class FundReportJob < ApplicationJob
  queue_as :balance_report_queue

  def perform(date = 1.day.ago.to_date)
    date = date.to_date
    report_data = {
      total_invested: FundOperation.total_invested(date),
      capitalization: FundBalanceReport.total_capitalization(date),
      daily_invested: FundOperation.daily_invested(date),
      total_fees:     FundOperation.daily_fees(date),
      currency:       Currency.default,
      report_date:    date
    }
    date_report = FundReport.by_report_date(date).first

    if date_report.present?
      date_report.assign_attributes(report_data)
    else 
      date_report = FundReport.new(report_data)
    end
    date_report.save!

    InvestorReportJob.perform_now(date.to_s)
    FundReportJob.perform_now((date + 1.day).to_s) if date < 1.day.ago.to_date
  end
end
