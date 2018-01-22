require 'test_helper'

class ExchangeRatesJobTest < ActiveJob::TestCase
  include ActiveJob::TestHelper

  test 'direct run job test' do
    btc_cur = create(:currency_btc)
    ltc_cur = create(:currency_ltc)
    usd_cur = create(:currency_usd)

    Coinpayments.stubs(:rates).returns(Hashie::Mash.new({
      USD: { rate_btc: 0.0002 },
      LTC: { rate_btc: 0.014 }
    }))

    usd_btc_rate = 0.0002
    btc_usd_rate = 5000
    ltc_rate     = 70

    assert_difference('ExchangeRate.count', 3) do
      ExchangeRatesJob.perform_now
    end
    assert_equal btc_usd_rate, ExchangeRate.rate_to_default(btc_cur).first.rate
    assert_equal ltc_rate, ExchangeRate.rate_to_default(ltc_cur).first.rate
    assert_equal usd_btc_rate, ExchangeRate.where(from_currency: usd_cur, to_currency: btc_cur)
      .order(created_at: :desc).first.rate
  end
end
