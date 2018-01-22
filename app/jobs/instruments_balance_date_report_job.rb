class InstrumentsBalanceDateReportJob < ApplicationJob
  queue_as :balance_report_queue

  def perform(date, instrument_id)
    Services::CalcBalances::CalcInstrumentReport.build_since_date(date, instrument_id)
  end
end
