require 'test_helper'

class DefaultCurrencyExchangeConcernModelTest
  include ActiveModel::Model
  include DefaultCurrencyExchangeConcern

  attr_accessor :amount, :currency

  def initialize(amount, currency)
    @amount   = amount
    @currency = currency
  end
end

class DefaultCurrencyExchangeConcernTest < ActionController::TestCase
  test 'amount to default' do
    currency      = create(:currency)
    obj           = DefaultCurrencyExchangeConcernModelTest.new(100.0, currency)
    exchange_rate = create(
      :exchange_rate,
      from_currency: obj.currency,
      to_currency: create(:currency_usd)
    )
    assert_equal exchange_rate.rate * obj.amount, obj.amount_to_default
  end

  test 'amount to default by date' do
    currency = create(:currency)
    usd      = create(:currency_usd)
    obj      = DefaultCurrencyExchangeConcernModelTest.new(100.0, currency)

    day_ago_rate = create(
      :exchange_rate,
      from_currency: obj.currency,
      to_currency: usd,
      created_at: 1.day.ago
    )

    assert_equal day_ago_rate.rate * obj.amount, obj.amount_to_default(1.day.ago)
    assert_equal day_ago_rate.rate * obj.amount, obj.amount_to_default

    today_rate = create(
      :exchange_rate,
      from_currency: obj.currency,
      to_currency: usd
    )

    assert_equal day_ago_rate.rate * obj.amount, obj.amount_to_default(1.day.ago)
    assert_equal today_rate.rate * obj.amount, obj.amount_to_default
  end

  test 'not found rates exception' do
    create(:currency_usd)
    currency = create(:currency)
    obj      = DefaultCurrencyExchangeConcernModelTest.new(100.0, currency)

    error = assert_raises(RuntimeError) { obj.amount_to_default(1.day.ago) }
    assert_equal "Could not find any exchange rates data for #{currency.symbol} currency", error.message
  end
end
