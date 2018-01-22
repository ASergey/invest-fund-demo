require 'test_helper'

class InstrumentsCapitalizationTest < ActiveSupport::TestCase
  setup do
    usd           = create(:currency_usd)
    btc           = create(:currency_btc)
    exchange_rate = create(:exchange_rate, from_currency: btc, to_currency: usd, rate: 5000.0)
    @instrument   = create(:instrument, instrument_type: 'default' )
    @hashnest     = create(:instrument, instrument_type: 'hashnest' )
    i_usd_balance = create(:instrument_balance, instrument: @instrument, currency: usd, amount: 10000.0)
    i_btc_balance = create(:instrument_balance, instrument: @instrument, currency: btc, amount: 1.0)
    h_balance     = create(:hashnest_btc_balance, instrument: @hashnest, currency: btc, amount: 0.1)
    # amount: 0.1, 
    # hash_code   'ants7'
    # hash_amount 100
    # hash_rate   0.1
    # hash_code   'ants9'
    # hash_amount 100
    # hash_rate   0.2
  end

  test 'capitalization' do
    assert_equal 10000.0 + 1.0 * 5000.0, @instrument.capitalization
    assert_equal (0.1 + 100 * 0.1 + 100 * 0.2) * 5000.0, @hashnest.capitalization
  end

  test 'all instruments total capitalization' do
    assert_equal (10000.0 + 1.0 * 5000.0) + (0.1 + 100 * 0.1 + 100 * 0.2) * 5000.0, Instrument.total_capitalization
  end
end
