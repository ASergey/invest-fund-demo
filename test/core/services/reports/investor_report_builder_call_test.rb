require 'test_helper'

class InvestorReportBuilderCallTest < ActiveSupport::TestCase
  setup do
    @usd          = create(:currency_usd, default: true)
    @report_date  = 1.day.ago.to_date
    @investor     = create(:user_investor)
    @builder      = Services::Reports::InvestorReportBuilder.new(@investor.id)
    @fund_balance = create(:fund_balance, currency: @usd, amount: 100_000.0)

    create(
      :fund_operation,
      :done,
      investor: @investor,
      amount: 10_000.0,
      currency: @usd,
      operation_date: 1.month.ago.to_date
    )
    create(
      :operation_investor_payout,
      :done,
      investor: @investor,
      amount: 2_000.0,
      currency: @usd,
      operation_date: 8.days.ago.to_date
    )
    create(
      :fund_operation,
      :done,
      investor: @investor,
      amount: 5_000.0,
      currency: @usd,
      operation_date: 5.days.ago.to_date
    )
  end

  test 'call investor_total' do
    @builder.call

    assert_equal @report_date, @builder.date
    assert_equal 10_000.0 - 2_000.0 + 5_000.0, @builder.investor_total
    assert_equal @builder.investor_total, @builder.cap_before
  end

  test 'call cap_before & daily_revenue' do
    @builder.investor_total = 10_000.0 - 2_000.0 + 5_000.0

    investor_report = create(
      :investor_report,
      user:           @investor,
      currency:       @usd,
      amount:         @builder.investor_total,
      capitalization: 15_000.0,
      daily_revenue:  0.5,
      daily_profit:   100.0,
      report_date:    2.days.ago.to_date
    )
    @builder.call

    assert_equal investor_report.capitalization, @builder.cap_before
    assert_equal @builder.investor_total / 113_000.0, @builder.daily_revenue
  end

  test 'call daily_revenue with existing fund_report' do
    create(
      :fund_report,
      currency: @usd,
      capitalization: 120_000.0,
      daily_invested: 0.0,
      total_fees:     0.0,
      report_date:    2.days.ago.to_date
    )
    @builder.call

    assert_equal @builder.cap_before / 120_000.0, @builder.daily_revenue
  end
end
