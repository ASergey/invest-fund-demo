class Services::CalcBalances::Fund
  include Services::CalcBalances::Concerns::FundCalcConcern

  def initialize(operation)
    @operation = operation
  end

  def call(apply_calc = true)
    return if @operation.currency.blank? || @operation.investor.blank?
    fund_balance = FundBalance.find_or_create_by(currency: @operation.currency)

    adjust_amount = calc_investment if @operation.operation_type.investment?
    adjust_amount = calc_payout if @operation.operation_type.payout? || @operation.operation_type.management_fee?

    fund_balance.amount = fund_balance.amount + adjust_amount
    fund_balance.save if apply_calc

    { fund_balance_amount: fund_balance.amount }
  end
end
