require 'test_helper'

class CalcBalancesTest
  include Services::CalcBalances::Concerns::FundCalcConcern

  attr_accessor :operation
end

class FundCalcConcernTest < ActionController::TestCase
  test 'calculate investment' do
    calc_balance = CalcBalancesTest.new
    calc_balance.operation = build(:fund_operation, :canceled, amount: 100.0)

    assert_equal(0.0, calc_balance.send(:calc_investment))
    assert_equal(0.0, calc_balance.send(:calc_payout))

    calc_balance.operation.status = FundOperation::STATUS_DONE
    assert_equal(100.0, calc_balance.send(:calc_investment))

    calc_balance.operation = create(:fund_operation, :done, amount: 100.0)
    calc_balance.operation.status = FundOperation::STATUS_CANCELED
    assert_equal(-100.0, calc_balance.send(:calc_investment))
  end

  test 'calculate payout' do
    calc_balance = CalcBalancesTest.new
    calc_balance.operation = build(:fund_operation, :payout, :canceled, amount: 100.0)

    assert_equal(0.0, calc_balance.send(:calc_investment))
    assert_equal(0.0, calc_balance.send(:calc_payout))

    calc_balance.operation.status = FundOperation::STATUS_DONE
    assert_equal(-100.0, calc_balance.send(:calc_payout))

    calc_balance.operation = create(:fund_operation, :done, amount: 100.0)
    calc_balance.operation.status = FundOperation::STATUS_CANCELED
    assert_equal(100.0, calc_balance.send(:calc_payout))
  end
end
