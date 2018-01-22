require 'test_helper'

class FundOperationBalanceValidatorTest < ActiveSupport::TestCase
  test 'fund balance investor payout success' do
    balance   = create(:fund_balance, :usd)
    currency  = balance.currency
    operation = build(:operation_investor_payout, :done, currency: currency, amount: 1000.00)

    assert operation.save
  end

  test 'fund balance instrument investment success' do
    balance   = create(:fund_balance, :btc)
    currency  = balance.currency
    operation = build(:operation_instrument_investment, :done, currency: currency, amount: 10.00)

    assert operation.save
  end

  test 'instrument balance payout success' do
    instrument_balance = create(:instrument_balance, :btc, amount: 20.00)
    instrument         = instrument_balance.instrument
    currency           = instrument_balance.currency

    create(:fund_balance, currency: currency)
    operation = build(:operation_instrument_payout, :done, instrument: instrument, currency: currency, amount: 10.00)

    assert operation.save
  end

  test 'insufficient fund balance to payout to investor' do
    balance   = create(:fund_balance, :usd, amount: 100.00)
    currency  = balance.currency
    operation = build(:operation_investor_payout, :done, currency: currency, amount: 1000.00)

    assert_not operation.save
    assert_equal I18n.t('validations.operation.insufficient_funds', amount: 1000.00, currency: currency.symbol), operation.errors[:operation_type].first
  end

  test 'insufficient fund balance to invest to instrument' do
    balance   = create(:fund_balance, :usd, amount: 100.00)
    currency  = balance.currency
    operation = build(:operation_instrument_investment, :done, currency: currency, amount: 1000.00)

    assert_not operation.save
    assert_equal I18n.t('validations.operation.insufficient_funds', amount: 1000.00, currency: currency.symbol), operation.errors[:operation_type].first
  end

  test 'insufficient instrument balance' do
    instrument_balance = create(:instrument_balance, :btc, amount: 10.00)
    instrument         = instrument_balance.instrument
    currency           = instrument_balance.currency

    create(:fund_balance, currency: currency)
    operation = build(:operation_instrument_payout, :done, instrument: instrument, currency: currency, amount: 30.00)

    assert_not operation.save
    assert_equal I18n.t('validations.operation.instrument_insufficient_funds', instrument: instrument.name, amount: operation.amount, currency: currency.symbol), operation.errors[:operation_type].first
  end

  test 'balance exception raises' do
    instrument_balance = create(:instrument_balance, :btc)
    instrument         = instrument_balance.instrument
    currency           = instrument_balance.currency
    operation          = build(:operation_instrument_investment, :done, instrument: instrument, currency: currency, amount: 30.00)

    assert_not operation.save
    assert_equal I18n.t('validations.fund_balance.not_found', currency: currency.symbol), operation.errors[:currency].first
  end
end
