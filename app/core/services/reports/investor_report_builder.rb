class Services::Reports::InvestorReportBuilder
  attr_accessor :daily_revenue, :capitalization, :date, :investor_total, :cap_before

  def initialize(investor_id)
    @investor = User.investor.find(investor_id)
  end

  def call(date = 1.day.ago.to_date)
    @date           = date.to_date
    @investor_total = FundOperation.investor_total_invested(@investor.id, @date)
    @cap_before     = calc_cap_before(@date)
    @daily_revenue  = calc_daily_revenue(@date)
    @capitalization = calc_capitalization(@date)
    @daily_profit   = calc_daily_profit(@capitalization)
    self
  end

  def report_data
    {
      user:           @investor,
      amount:         @investor_total,
      daily_revenue:  @daily_revenue,
      capitalization: @capitalization,
      daily_profit:   @daily_profit,
      currency:       Currency.default,
      report_date:    @date
    }
  end

  def normalize_revenue_share(factor)
    @daily_revenue /= factor
    @capitalization = calc_capitalization(@date)
    @daily_profit   = calc_daily_profit(@capitalization)
    @daily_revenue
  end

  private

  def calc_cap_before(date)
    result = InvestorReport.capitalization_before_date(@investor.id, date)
    # are there any investments earlier this month?
    if result.blank? && FundOperation.investor_investment_before?(@investor.id, date)
      # seems to be new investment
      result = @investor_total if @investor_total.present? # investor total balance is its current capitalization in this case
    end
    result.present? ? result : 0.0
  end

  def calc_daily_revenue(date)
    fund_cap_before = FundReport.capitalization_before_date(date)

    if fund_cap_before.blank? # take today cap & today investor totals
      fund_cap     = FundBalance.total_capitalization
      investor_cap = @investor_total
      return investor_cap.present? && fund_cap.present? && fund_cap.positive? ? investor_cap / fund_cap : 0.0
    end

    @cap_before.present? ? @cap_before / fund_cap_before : 0.0
  end

  def calc_daily_profit(capitalization)
    @cap_before.present? ? capitalization - @cap_before : 0.0
  end

  def calc_capitalization(date)
    return 0.0 if @daily_revenue.blank?

    cap = date == 1.day.ago.to_date ? FundBalance.total_capitalization : FundReport.capitalization_by_date(date)
    cap = FundBalance.total_capitalization if cap.nil?

    cap.present? ? cap * @daily_revenue : 0.0
  end
end
