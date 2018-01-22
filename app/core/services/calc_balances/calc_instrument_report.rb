class Services::CalcBalances::CalcInstrumentReport
  include Services::CalcBalances::Concerns::FundCalcConcern

  def initialize(operation)
    @operation = operation
  end

  def call
    return if @operation.instrument.blank?
    amount = adjust_report_amount
    InstrumentReport.by_instrument(@operation.instrument_id)
                    .by_currency(@operation.currency_id)
                    .later_than(@operation.operation_date)
                    .update_all("amount = amount + #{amount}")

    self.class.build_since_date(@operation.operation_date, @operation.instrument_id, amount, @operation.currency_id)
  end

  def self.build_since_date(date_from, instrument_id, amount = 0.0, currency_id = nil)
    return if date_from.to_date > 1.day.ago.to_date

    new_reports = []
    InstrumentBalance.by_instrument(instrument_id).each do |balance|
      new_reports += build_balance_reports(date_from, balance, amount, currency_id)
    end

    InstrumentReport.create(new_reports) if new_reports.present?
  end

  def self.build_balance_reports(date_from, balance, amount = 0.0, currency_id = nil)
    prev_amount       = currency_id.present? && currency_id == balance.currency_id ? amount : 0.0
    prev_hash_reports = nil
    new_reports       = []
    reports           = InstrumentReport.by_instrument(balance.instrument_id)
                                        .by_currency(balance.currency_id)
                                        .later_than(date_from)

    (date_from.to_date..1.day.ago.to_date).each do |day|
      date_report = reports.find { |report| report.report_date == day }
      if date_report.present?
        prev_amount       = date_report.amount
        prev_hash_reports = date_report.hash_reports_data_list
        next
      end
      report = {
        instrument_id: balance.instrument_id,
        currency:      balance.currency,
        amount:        prev_amount,
        report_date:   day
      }
      report[:instrument_hash_reports_attributes] = prev_hash_reports if prev_hash_reports.present?

      new_reports << report
    end
    new_reports
  end

  private

  def adjust_report_amount
    return @operation.operation_type.investment? ? calc_investment : calc_payout
  end
end
