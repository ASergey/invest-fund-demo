class InstrumentsBalanceReportJob < ApplicationJob
  queue_as :balance_report_queue

  def perform(instrument_id)
    instrument = Instrument.find(instrument_id)

    daily_report = []
    instrument.instrument_balances.each do |balance|
      next if balance.total_balance.nil?

      last_day_report = InstrumentReport.last_day_report(balance.currency_id, instrument.id)
      report_params = {
        instrument:  instrument,
        currency:    balance.currency,
        amount:      balance.amount,
        report_date: 1.day.ago.to_date
      }
      if balance.instrument_hash_balances.present?
        report_params[:instrument_hash_reports_attributes] = balance.build_hash_report(last_day_report)
      end

      if last_day_report.present?
        last_day_report.assign_attributes(report_params)
        last_day_report.save!
      else
        daily_report << report_params
      end
    end

    InstrumentReport.create!(daily_report) if daily_report.present?
  end
end
