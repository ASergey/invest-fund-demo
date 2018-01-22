module Services::CalcBalances::Concerns::FundCalcConcern
  extend ActiveSupport::Concern

  private

  def calc_investment
    return @operation.amount if @operation.made_done?
    return -@operation.amount if @operation.made_undone?
    0.0
  end

  def calc_payout
    return -@operation.amount if @operation.made_done?
    return @operation.amount if @operation.made_undone?
    0.0
  end
end