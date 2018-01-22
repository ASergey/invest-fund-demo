class InvestorReportJob < ApplicationJob
  queue_as :balance_report_queue

  def perform(date = 1.day.ago.to_date)
    report_builders = []
    User.investor.each do |investor|
      report_builder = Services::Reports::InvestorReportBuilder.new(investor.id)
      report_builders << report_builder.call(date) if report_builder.present?
    end

    total_revenue = report_builders.sum { |rb| rb.report_data[:daily_revenue] }
    if total_revenue != 1
      report_builders.map do |report_builder|
        report_builder.normalize_revenue_share(total_revenue)
      end
    end

    report_builders.each do |report_builder|
      report_data = report_builder.report_data
      date_report = InvestorReport.by_date_report(report_data[:user].id, date)
      if date_report.present?
        date_report.assign_attributes(report_data)
      else
        date_report = InvestorReport.new(report_data)
      end
      date_report.save!

      InvestorDividendsJob.perform_later(report_data[:user].id) if date.to_s == date.to_date.end_of_month.to_s
    end
  end
end
