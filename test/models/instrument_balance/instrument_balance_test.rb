require 'test_helper'

class InstrumentBalanceTest < ActiveSupport::TestCase
  test 'total balance default type' do
    i_balance = create(:instrument_balance, amount: 100.0)
    assert_equal 100, i_balance.total_balance
  end

  test 'total balance hashnest (bixin) type' do
    i_balance = create(:hashnest_ltc_balance, amount: 10.0)
    assert_equal 100.0 * 0.5 + 10.0, i_balance.total_balance

    j_balance = create(:hashnest_btc_balance, amount: 0.1)
    assert_equal 100 * 0.2 + 100 * 0.1 + 0.1, j_balance.total_balance
  end

  test 'build_hash_report' do
    balance = create(:instrument_balance, :btc)

    assert_nil balance.build_hash_report

    ants7_balance = create(:instrument_hash_balance, :hashnest_ants7, instrument_balance: balance)
    ants9_balance = create(:instrument_hash_balance, :hashnest_ants9, instrument_balance: balance)

    ants7_balance_attrs = {
      hash_amount: ants7_balance.hash_amount,
      hash_rate:   ants7_balance.hash_rate,
      hash_code:   ants7_balance.hash_code
    }
    ants9_balance_attrs = {
      hash_amount: ants9_balance.hash_amount,
      hash_rate:   ants9_balance.hash_rate,
      hash_code:   ants9_balance.hash_code
    }

    assert_kind_of Array, balance.build_hash_report

    assert_includes balance.build_hash_report, ants7_balance_attrs
    assert_includes balance.build_hash_report, ants9_balance_attrs

    report = create(:instrument_report, currency: balance.currency, instrument: balance.instrument)
    ants7_report = create(:instrument_hash_report, :hashnest_ants7, instrument_report: report)
    ants9_report = create(:instrument_hash_report, :hashnest_ants9, instrument_report: report)

    assert_kind_of Array, balance.build_hash_report(report)
    assert_includes balance.build_hash_report(report), ants7_balance_attrs.merge(id: ants7_report.id)
    assert_includes balance.build_hash_report(report), ants9_balance_attrs.merge(id: ants9_report.id)
  end
end
