class Services::CalcBalances::Instrument
  include Services::CalcBalances::Concerns::FundCalcConcern

  def initialize(operation)
    @operation = operation
  end

  def call(apply_calc = true)
    return if @operation.currency.blank? || @operation.instrument.blank?
    fund_balance = FundBalance.find_by(currency: @operation.currency)
    raise I18n.t('validations.fund_balance.not_found', currency: @operation.currency.symbol) if fund_balance.blank?
    instrument_balance = InstrumentBalance.find_or_create_by(instrument: @operation.instrument,
                                                             currency: @operation.currency)

    adjust_amount = calc_investment if @operation.operation_type.investment?
    adjust_amount = calc_payout if @operation.operation_type.payout?

    fund_balance.amount       = fund_balance.amount - adjust_amount
    instrument_balance.amount = instrument_balance.amount + adjust_amount

    if apply_calc
      fund_balance.save
      instrument_balance.save
    end

    { fund_balance_amount: fund_balance.amount, subject_balance_amount: instrument_balance.amount }
  end
end
