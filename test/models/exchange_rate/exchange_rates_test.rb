require 'test_helper'

class ExchangeRatesTest < ActiveSupport::TestCase
  setup do
    @btc_cur = create(:currency_btc)
    @ltc_cur = create(:currency_ltc)
    @usd_cur = create(:currency_usd)
    @btc_day_ago_rate = create(
      :exchange_rate,
      rate:          5000,
      from_currency: @btc_cur,
      to_currency:   @usd_cur,
      created_at:    1.day.ago
    )
    @ltc_day_ago_rate = create(
      :exchange_rate,
      rate:          60,
      from_currency: @ltc_cur,
      to_currency:   @usd_cur,
      created_at:    1.day.ago
    )
  end

  test 'convert to default' do
    assert_equal 5000 * 10, ExchangeRate.convert_to_default(10, @btc_cur)
    assert_equal 100, ExchangeRate.convert_to_default(100, @usd_cur)

    ltc_today_rate = create(
      :exchange_rate,
      rate:          65,
      from_currency: @ltc_cur,
      to_currency:   @usd_cur
    )

    assert_equal 50 * 65, ExchangeRate.convert_to_default(50, @ltc_cur)
  end

  test 'convert to default by date' do
    assert_equal 5000 * 10, ExchangeRate.convert_to_default(10, @btc_cur, 1.day.ago)
    assert_equal 100, ExchangeRate.convert_to_default(100, @usd_cur, 1.day.ago)

    assert_raises I18n.t('report.exchange_rate_error', currency: @btc_cur.symbol) do
      ExchangeRate.convert_to_default(10, @btc_cur, 10.days.ago)
    end
  end

  test 'today' do
    assert_empty ExchangeRate.today

    btc_today_rate = create(
      :exchange_rate,
      rate:          5000,
      from_currency: @btc_cur,
      to_currency:   @usd_cur
    )
    ltc_today_rate = create(
      :exchange_rate,
      rate:          60,
      from_currency: @ltc_cur,
      to_currency:   @usd_cur
    )
    today_rates = ExchangeRate.today
    assert_not_empty today_rates
    assert_includes today_rates, btc_today_rate
    assert_includes today_rates, ltc_today_rate
  end

  test 'rate_to_currency' do
    ltc_usd_rate = create(
      :exchange_rate,
      rate:          60.0,
      from_currency: @ltc_cur,
      to_currency:   @usd_cur,
      created_at:    1.day.ago
    )
    ltc_usd_rate2 = create(
      :exchange_rate,
      rate:          65.0,
      from_currency: @ltc_cur,
      to_currency:   @usd_cur,
      created_at:    2.days.ago
    )
    ltc_btc_rate = create(
      :exchange_rate,
      rate:          5.5,
      from_currency: @ltc_cur,
      to_currency:   @btc_cur,
      created_at:    5.days.ago
    )

    assert_nil ExchangeRate.rate_to_currency(@btc_cur.id, @ltc_cur.id)
    assert_nil ExchangeRate.rate_to_currency(@usd_cur.id, @ltc_cur.id)

    assert_not_nil ExchangeRate.rate_to_currency(@ltc_cur.id, @usd_cur.id)
    assert_equal 60.0, ExchangeRate.rate_to_currency(@ltc_cur.id, @usd_cur.id).rate

    assert_not_nil ExchangeRate.rate_to_currency(@ltc_cur.id, @btc_cur.id)
    assert_equal 5.5, ExchangeRate.rate_to_currency(@ltc_cur.id, @btc_cur.id).rate
  end
end
