require 'test_helper'

class InstrumentTest < ActiveSupport::TestCase
  setup do
    @currency   = create(:currency_btc)
    @f_balance  = create(:fund_balance, currency: @currency)
    @instrument = create(:instrument)
    @i_balance  = create(:instrument_balance, currency: @currency, instrument: @instrument)
  end

  test 'operation pending' do
    pending_operation = create(:operation_instrument_investment, instrument: @instrument, currency: @currency)
    pending_operation.expects(:calc_balances).never
  end

  test 'operation created canceled' do
    fb_before = @f_balance.amount
    ib_before = @i_balance.amount
    create(:operation_instrument_investment, :canceled, instrument: @instrument, currency: @currency)

    @f_balance.reload
    @i_balance.reload

    assert_equal fb_before, @f_balance.amount
    assert_equal ib_before, @i_balance.amount
  end

  test 'operation set from pending to canceled' do
    fb_before = @f_balance.amount
    ib_before = @i_balance.amount

    operation = create(:operation_instrument_investment, instrument: @instrument, currency: @currency)

    @f_balance.reload
    @i_balance.reload
    assert_equal fb_before, @f_balance.amount
    assert_equal ib_before, @i_balance.amount

    operation.update(status: FundOperation::STATUS_CANCELED)

    @f_balance.reload
    @i_balance.reload
    assert_equal fb_before, @f_balance.amount
    assert_equal ib_before, @i_balance.amount
  end

  test 'operation set from done to canceled' do
    fb_before    = @f_balance.amount
    ib_before    = @i_balance.amount

    operation = create(
      :operation_instrument_investment,
      :done,
      instrument: @instrument,
      currency: @currency,
      amount: 10.00
    )

    @f_balance.reload
    @i_balance.reload
    assert_not_equal fb_before, @f_balance.amount
    assert_not_equal ib_before, @i_balance.amount

    operation.update(status: FundOperation::STATUS_CANCELED)

    @f_balance.reload
    @i_balance.reload
    assert_equal fb_before, @f_balance.amount
    assert_equal ib_before, @i_balance.amount
  end

  test 'operation done' do
    fb_before = @f_balance.amount
    ib_before = @i_balance.amount
    operation = create(
      :operation_instrument_investment,
      :done,
      currency: @currency,
      instrument: @instrument,
      amount: 10.00
    )

    @f_balance.reload
    @i_balance.reload

    assert_equal operation.amount, fb_before - @f_balance.amount
    assert_equal operation.amount, @i_balance.amount - ib_before
  end

  test 'operation from canceled to done' do
    fb_before = @f_balance.amount
    ib_before = @i_balance.amount

    canceled_operation = create(
      :operation_instrument_investment,
      :canceled,
      currency: @currency,
      instrument: @instrument,
      amount: 10.00
    )
    canceled_operation.update(status: FundOperation::STATUS_DONE)

    @f_balance.reload
    @i_balance.reload

    assert_equal canceled_operation.amount, fb_before - @f_balance.amount
    assert_equal canceled_operation.amount, @i_balance.amount - ib_before
  end

  test 'operation from pending to done' do
    fb_before = @f_balance.amount
    ib_before = @i_balance.amount

    pending_operation = create(
      :operation_instrument_investment,
      currency: @currency,
      instrument: @instrument,
      amount: 10.00
    )
    pending_operation.update(status: FundOperation::STATUS_DONE)

    @f_balance.reload
    @i_balance.reload

    assert_equal pending_operation.amount, fb_before - @f_balance.amount
    assert_equal pending_operation.amount, @i_balance.amount - ib_before
  end

  test 'operation payout done' do
    fb_before = @f_balance.amount
    ib_before = @i_balance.amount
    operation = create(:operation_instrument_payout, :done, currency: @currency, instrument: @instrument, amount: 10.00)

    @f_balance.reload
    @i_balance.reload

    assert_equal operation.amount, @f_balance.amount - fb_before
    assert_equal operation.amount, ib_before - @i_balance.amount
  end
end
