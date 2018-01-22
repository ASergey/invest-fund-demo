require 'test_helper'

class FundOperationTotalsMethodsTest < ActiveSupport::TestCase
  setup do
    @usd = create(:currency_usd)
    @btc = create(:currency_btc)

    rate = 4500.00
    (5.days.ago.to_date..1.day.ago.to_date).each do |date|
      create(:exchange_rate,
             rate:          rate,
             from_currency: @btc,
             to_currency:   @usd,
             created_at:    date)
      rate += 100.0

      create(:fund_operation, currency: @usd, amount: 1000.0, operation_date: date)
      create(:fund_operation, :done, currency: @usd, amount: 1000.0, operation_date: date)
      create(:fund_operation, :done, currency: @btc, amount: 1.0, operation_date: date)
      create(:fund_operation, :done, currency: @btc, amount: 1.0, operation_date: date)
      create(:operation_investor_payout, :done, currency: @btc, amount: 1.0, operation_date: date)
    end
  end

  test 'fund operation amount to default currency (convert_by_date_rate)' do
    operation_usd = create(:fund_operation, currency: @usd)
    operation_btc = create(:fund_operation, currency: @btc)
    grouped_operation_row = stub(amount: operation_btc.amount, rate: 5000.0, currency_id: @btc.id)
    assert_equal operation_usd.amount, FundOperation.convert_by_date_rate(operation_usd, @usd)
    assert_equal operation_btc.amount * 5000.0, FundOperation.convert_by_date_rate(grouped_operation_row, @usd)
  end

  test 'group_amount_with_rates' do
    grouped_rates_amount = FundOperation.group_amount_with_rates
    grouped_rates_amount.each do |row|
      assert %w[amount currency_id rate].all? { |a| row.attributes.keys.include?(a) }
      assert_not_nil row.rate unless row.currency_id == @usd.id
      assert_not_nil row.amount
      assert_equal 3.0, row.amount if row.currency_id == @btc.id
      assert_equal 2000.0, row.amount if row.currency_id == @usd.id
    end
    assert_equal 10, grouped_rates_amount.size
  end

  test 'total investments made done that day (daily invested)' do
    assert_equal 1000.0 + 2.0 * 4900.0, FundOperation.daily_invested
    assert_equal 1000.0 + 2.0 * 4800.0, FundOperation.daily_invested(2.days.ago)
  end

  test 'total fees paid out (done) that day (daily_fees)' do
    create(:operation_management_fee, currency: @usd)
    create(:operation_management_fee, :done, operation_date: 1.day.ago.to_date, currency: @usd, amount: 100.0)
    create(:operation_management_fee, :done, operation_date: 1.day.ago.to_date, currency: @usd, amount: 300.0)

    today_management_fee     = create(:operation_management_fee, :done, currency: @usd, amount: 100.0)
    today_management_fee_btc = create(:operation_management_fee, :done, currency: @usd, amount: 2.0)
    today_expected_fee = today_management_fee.amount + ExchangeRate.convert_to_default(
      today_management_fee_btc.amount,
      today_management_fee_btc.currency
    )

    assert_equal today_expected_fee, FundOperation.daily_fees(Date.current)
    assert_equal 100.0 + 300.0, FundOperation.daily_fees(1.day.ago.to_date)
  end

  test 'sum of all investments by date (total_invested)' do
    total_invested = 0.0
    rate           = 4500.0

    (5.days.ago.to_date..1.day.ago.to_date).each do
      total_invested += 1000.0 + 1 * rate
      rate += 100.0
    end

    assert_equal total_invested, FundOperation.total_invested

    create(:operation_management_fee, :done, currency: @usd, amount: 100.0)
    assert_equal total_invested, FundOperation.total_invested

    create(:operation_management_fee, :done, currency: @usd, amount: 100.0, operation_date: 1.day.ago.to_date)
    assert_equal total_invested - 100.0, FundOperation.total_invested
  end

  test 'sum investor funds by date (investor_total_invested)' do
    investor = create(:user_investor)
    create(:fund_operation,
           :done,
           currency: @usd,
           amount: 1000.0,
           operation_date: 1.day.ago.to_date,
           investor: investor)
    create(:fund_operation, :done, currency: @btc, amount: 1.0, operation_date: 1.day.ago.to_date, investor: investor)
    create(:fund_operation, :done, currency: @btc, amount: 1.0, operation_date: 5.days.ago.to_date, investor: investor)

    total_invested = 1000.0 + 1.0 * 4900.0 + 1.0 * 4500.0
    assert_equal total_invested, FundOperation.investor_total_invested(investor.id)

    create(:fund_operation, :done, currency: @btc, amount: 1.0, investor: investor)
    create(:operation_management_fee, :done, currency: @usd, amount: 100.0, investor: investor)

    assert_equal total_invested, FundOperation.investor_total_invested(investor.id)

    create(:operation_management_fee,
           :done,
           currency: @usd,
           amount: 100.0,
           operation_date: 4.days.ago.to_date,
           investor: investor)

    assert_equal total_invested - 100.0, FundOperation.investor_total_invested(investor.id)
  end
end
