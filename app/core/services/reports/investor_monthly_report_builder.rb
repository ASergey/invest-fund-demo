class Services::Reports::InvestorMonthlyReportBuilder
  include ApplicationHelper

  attr_accessor :amount, :fee_amount

  def initialize(investor_id)
    @investor = User.investor.find(investor_id)
    return nil if @investor.blank?

    @amount     = InvestorReport.monthly_profit(@investor.id, last_month_date)
    @fee_amount = calc_management_fee

    raise I18n.t('report.monthly_insufficient_data_error', investor_id: investor_id) if @fee_amount.blank?
    self
  end

  def call
    @monthly_report = InvestorMonthlyReport.find_by(user: @investor, report_date: last_month_date)
    if @monthly_report.present?
      @monthly_report.update!(report_data)
    else
      @monthly_report = InvestorMonthlyReport.create!(report_data)
    end
    return false if @monthly_report.blank?

    if divident_amount_positive?
      reinvest_dividend(payout_amount) if @investor.reinvest?
      payout_dividend(payout_amount) unless @investor.reinvest?
    end
    payout_management_fee(fee_amount)
    report_data
  end

  private

  def report_data
    {
      user:            @investor,
      dividend_amount: @amount,
      management_fee:  @fee_amount,
      payout_amount:   payout_amount,
      currency:        Currency.default,
      report_date:     last_month_date
    }
  end

  def divident_amount_positive?
    @amount.positive? && (@amount - @fee_amount).positive?
  end

  def payout_amount
    divident_amount_positive? ? @amount - @fee_amount : 0.0
  end

  def payout_dividend(amount)
    FundOperation.create!(
      user:           User.with_role(RoleName::ADMIN).first,
      investor:       @investor,
      amount:         amount,
      currency:       Currency.default,
      operation_type: FundOperation::TYPE_PAYOUT,
      status:         FundOperation::STATUS_PENDING,
      notes:          I18n.t('report.divident_payout_note', report_id: @monthly_report.id),
      operation_date: Date.current
    )
  end

  def reinvest_dividend(amount)
    payout = {
      user:           User.with_role(RoleName::ADMIN).first,
      investor:       @investor,
      amount:         amount,
      currency:       Currency.default,
      operation_type: FundOperation::TYPE_PAYOUT,
      status:         FundOperation::STATUS_DONE,
      notes:          I18n.t('report.payout_reinvest_note', report_id: @monthly_report.id),
      operation_date: Date.current,
      validated_scopes: %i[no_balance]
    }
    investment = {
      user:           User.with_role(RoleName::ADMIN).first,
      investor:       @investor,
      amount:         amount,
      currency:       Currency.default,
      operation_type: FundOperation::TYPE_INVESTMENT,
      status:         FundOperation::STATUS_DONE,
      notes:          I18n.t('report.invest_reinvest_note', report_id: @monthly_report.id),
      operation_date: Date.current,
      validated_scopes: %i[no_balance]
    }

    FundOperation.transaction do
      FundOperation.create!([payout, investment])
    end
  end

  def payout_management_fee(amount)
    FundOperation.create!(
      user:           User.with_role(RoleName::ADMIN).first,
      investor:       @investor,
      amount:         amount,
      currency:       Currency.default,
      operation_type: FundOperation::TYPE_MANAGEMENT_FEE,
      status:         FundOperation::STATUS_PENDING,
      operation_date: Date.current
    )
  end

  def calc_management_fee
    report = InvestorReport.by_date_report(@investor.id, last_month_date)
    return if report.blank?

    report.capitalization * Setting.management_fee
  end
end
