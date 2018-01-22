class Services::CalcBalances::CalcFundReport
  include Services::CalcBalances::Concerns::FundCalcConcern

  def initialize(operation)
    @operation = operation
  end

  def call
    return if @operation.currency.blank? || @operation.operation_date.blank?
    self.class.build_since_date(@operation.operation_date, adjust_report_amount, @operation.currency_id)
  end

  def self.build_since_date(date, amount = 0.0, currency_id = nil)
    return if date.to_date > 1.day.ago.to_date

    new_reports = []
    FundBalance.all.each do |balance|
      reports = FundBalanceReport.by_currency(balance.currency.id).later_than(date)
      reports.update_all("amount = amount + #{amount}") if amount != 0.0 && currency_id == balance.currency.id

      prev_amount = currency_id.present? && currency_id == balance.currency_id ? amount : 0.0
      (date.to_date..1.day.ago.to_date).each do |day|
        date_report = reports.find { |report| report.report_date == day }
        if date_report.present?
          prev_amount = date_report.amount
          next
        end
        new_reports << { currency: balance.currency, amount: prev_amount, report_date: day }
      end
    end
    FundBalanceReport.create(new_reports) if new_reports.present?
  end

  private

  def adjust_report_amount
    result = @operation.operation_type.investment? ? calc_investment : calc_payout
    result = -result if @operation.instrument.present?
    result
  end
end
