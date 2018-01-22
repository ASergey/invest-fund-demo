class FundBalanceReportJob < ApplicationJob
  queue_as :balance_report_queue

  def perform
    balance_daily_report = []
    FundBalance.all.each do |balance|
      report = {
        currency:    balance.currency,
        amount:      balance.amount,
        report_date: 1.day.ago.to_date
      }

      yesterday_report = FundBalanceReport.last_day_report(balance.currency_id)
      if yesterday_report.present?
        yesterday_report.assign_attributes(report)
        yesterday_report.save!
      else
        balance_daily_report << report
      end
    end

    FundBalanceReport.create!(balance_daily_report) if balance_daily_report.present?
  end
end
