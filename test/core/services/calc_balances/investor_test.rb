require 'test_helper'

class InvestorTest < ActiveSupport::TestCase
  setup do
    @currency     = create(:currency_btc)
    @wallet       = create(:investor_wallet, currency: @currency)
    @investor     = create(:user_investor, investor_wallets: [@wallet])
    @wallet       = @investor.investor_wallets.first
    @kyc_doc      = create(:kyc_document, user: @investor)
    @f_balance    = create(:fund_balance, currency: @currency)
  end

  test 'operation pending' do
    pending_operation = create(:fund_operation, :wallet_payment, investor: @investor, wallet: @wallet, currency: @currency)
    pending_operation.expects(:calc_balances).never
  end

  test 'operation created canceled' do
    fb_before = @f_balance.amount
    create(:fund_operation, :canceled, :wallet_payment, investor: @investor, wallet: @wallet, currency: @currency)

    @f_balance.reload

    assert_equal fb_before, @f_balance.amount
  end

  test 'operation set from pending to canceled' do
    fb_before = @f_balance.amount

    operation = create(:fund_operation, :wallet_payment, investor: @investor, wallet: @wallet, currency: @currency)

    @f_balance.reload
    assert_equal fb_before, @f_balance.amount

    operation.update(status: FundOperation::STATUS_CANCELED)

    @f_balance.reload
    assert_equal fb_before, @f_balance.amount
  end

  test 'operation set from done to canceled' do
    fb_before    = @f_balance.amount

    operation = create(:fund_operation, :done, :wallet_payment, investor: @investor, wallet: @wallet, currency: @currency)

    @f_balance.reload
    assert_not_equal fb_before, @f_balance.amount

    operation.update(status: FundOperation::STATUS_CANCELED)
    
    @f_balance.reload
    assert_equal fb_before, @f_balance.amount
  end

  test 'operation done' do
    fb_before = @f_balance.amount
    operation = create(:fund_operation, :done, currency: @currency, investor: @investor)

    @f_balance.reload

    assert_equal operation.amount, @f_balance.amount - fb_before
  end

  test 'operation from canceled to done' do
    fb_before = @f_balance.amount

    canceled_operation = create(:fund_operation, :canceled, currency: @currency, investor: @investor)
    canceled_operation.update(status: FundOperation::STATUS_DONE)

    @f_balance.reload

    assert_equal canceled_operation.amount, @f_balance.amount - fb_before
  end

  test 'operation from pending to done' do
    fb_before = @f_balance.amount

    pending_operation = create(:fund_operation, currency: @currency, investor: @investor)
    pending_operation.update(status: FundOperation::STATUS_DONE)

    @f_balance.reload

    assert_equal pending_operation.amount, @f_balance.amount - fb_before
  end

  # test 'operation status did not change' do
  # end

  # test 'investor investment done' do
  #   # TODO: must update investor and fund balances
  # end

  # test 'investor payout done' do
  #   # TODO: must update investor and fund balances
  # end

  # test 'instrument investment done' do
  # end

  # test 'instrument payout done' do
  # end

  # test 'management fees payout pending' do
  #   # TODO: must show available amount for fees payout
  # end

  # test 'management fees payout available' do
  # end

  # test 'management fees payout not available' do
  # end

  # test 'interest fees payout available' do
  # end

  # test 'interest fees payout not available' do
  # end
end
