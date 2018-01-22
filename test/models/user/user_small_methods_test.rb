require 'test_helper'

class UserSmallMethodsTest < ActiveSupport::TestCase
  setup do
    @currency_btc = create(:currency_btc)
    @currency_ltc = create(:currency_ltc)
    @wallet_btc   = create(:investor_wallet, currency: @currency_btc)
    @wallet_ltc   = create(:investor_wallet, currency: @currency_ltc)
    @investor     = create(:user_investor, investor_wallets: [@wallet_btc, @wallet_ltc])
  end

  test 'first_investment: not investor' do
    user = create(:user)
    assert_nil user.first_investment
  end

  test 'first_investment: no investments or pending|canceled' do
    create(:fund_operation, :wallet_payment, investor: @investor, wallet: @wallet_ltc, currency: @currency_ltc)
    create(:fund_operation, :canceled, :wallet_payment, 
      investor: @investor,
      wallet: @wallet_ltc,
      currency: @currency_ltc)
    create(:fund_balance, currency: @currency_btc, amount: 1.0)
    create(:operation_investor_payout, :payout, :done, :wallet_payment,
      investor: @investor,
      wallet: @wallet_btc,
      currency: @currency_btc,
      amount: 1.0
    )

    assert_nil @investor.first_investment
  end

  test 'first_investment' do
    assert_nil @investor.first_investment

    create(:fund_operation, :wallet_payment, investor: @investor, wallet: @wallet_ltc, currency: @currency_ltc)
    create(:fund_operation, :payout, :wallet_payment, investor: @investor, wallet: @wallet_btc, currency: @currency_btc)
    done_investment = create(:fund_operation, :done, :wallet_payment,
      investor: @investor,
      wallet: @wallet_btc,
      currency: @currency_btc)
    create(:fund_operation, :done, :wallet_payment,
      investor: @investor,
      wallet: @wallet_ltc,
      currency: @currency_ltc)

    assert_equal done_investment.id, @investor.first_investment.id
  end

  test 'total_invested' do
    amount_btc = [10.0, 0.005, 0.0006]
    amount_ltc = [110.0, 2.55]

    create(:fund_balance, currency: @currency_ltc, amount: 100.0)

    assert_empty @investor.total_invested

    amount_btc.each do |amount|
      create(:fund_operation, :wallet_payment, :done, investor: @investor, wallet: @wallet_btc, currency: @currency_btc, amount: amount)
    end
    create(:fund_operation, :wallet_payment, investor: @investor, wallet: @wallet_btc, currency: @currency_btc, amount: 20.0)
    create(:fund_operation, :wallet_payment, :canceled, investor: @investor, wallet: @wallet_btc, currency: @currency_btc, amount: 10.0)

    amount_ltc.each do |amount|
      create(:fund_operation, :wallet_payment, :done, investor: @investor, wallet: @wallet_ltc, currency: @currency_ltc, amount: amount)
    end
    create(:fund_operation, :wallet_payment, investor: @investor, wallet: @wallet_ltc, currency: @currency_ltc, amount: 20.0)
    create(:fund_operation, :wallet_payment, :canceled, investor: @investor, wallet: @wallet_ltc, currency: @currency_ltc, amount: 10.0)

    create(:operation_investor_payout, :wallet_payment, :done, investor: @investor, wallet: @wallet_ltc, currency: @currency_ltc, amount: 100.0)
    create(:operation_investor_payout, :wallet_payment, :done, investor: @investor, wallet: @wallet_btc, currency: @currency_btc, amount: 5.0)

    assert_not_nil @investor.total_invested
    assert_equal amount_btc.sum, @investor.total_invested[@currency_btc].to_f
    assert_equal amount_ltc.sum, @investor.total_invested[@currency_ltc].to_f
  end

  test 'total_paid_out' do
    create(:fund_balance, currency: @currency_btc, amount: 50.0)
    create(:fund_balance, currency: @currency_ltc, amount: 200.0)

    amount_btc = [10.0, 0.005, 0.0006]
    amount_ltc = [110.0, 2.55]

    assert_empty @investor.total_paid_out

    amount_btc.each do |amount|
      create(:operation_investor_payout, :wallet_payment, :done, investor: @investor, wallet: @wallet_btc, currency: @currency_btc, amount: amount)
    end
    create(:operation_investor_payout, :wallet_payment, investor: @investor, wallet: @wallet_btc, currency: @currency_btc, amount: 20.0)
    create(:operation_investor_payout, :wallet_payment, :canceled, investor: @investor, wallet: @wallet_btc, currency: @currency_btc, amount: 10.0)
    create(:fund_operation, :wallet_payment, :done, investor: @investor, wallet: @wallet_btc, currency: @currency_btc, amount: 20.0)

    amount_ltc.each do |amount|
      create(:operation_investor_payout, :wallet_payment, :done, investor: @investor, wallet: @wallet_ltc, currency: @currency_ltc, amount: amount)
    end
    create(:operation_investor_payout, :wallet_payment, investor: @investor, wallet: @wallet_ltc, currency: @currency_ltc, amount: 20.0)
    create(:operation_investor_payout, :wallet_payment, :canceled, investor: @investor, wallet: @wallet_ltc, currency: @currency_ltc, amount: 10.0)
    create(:fund_operation, :wallet_payment, :done, investor: @investor, wallet: @wallet_ltc, currency: @currency_ltc, amount: 20.0)

    assert_not_nil @investor.total_paid_out
    assert_equal amount_btc.sum, @investor.total_paid_out[@currency_btc].to_f
    assert_equal amount_ltc.sum, @investor.total_paid_out[@currency_ltc].to_f
  end
end
