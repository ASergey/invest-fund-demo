class ExchangeRatesJob < ApplicationJob
  queue_as :exchange_rates_queue

  def perform
    default_currency = Currency.default
    btc_currency     = Currency.find_by!(symbol: 'BTC')
    rates            = Coinpayments.rates

    exchange_rates = [
      { from_currency: btc_currency, to_currency: default_currency, rate: 1 / rates[default_currency.symbol.upcase.to_sym].rate_btc.to_f },
      { from_currency: default_currency, to_currency: btc_currency, rate: rates[default_currency.symbol.upcase.to_sym].rate_btc.to_f }
    ]
    Currency.all.each do |currency|
      next if currency.default?
      next if currency.id == btc_currency.id

      exchange_rates << {
        from_currency: currency,
        to_currency:   default_currency,
        rate:          rates[currency.symbol.upcase.to_sym].rate_btc.to_f / rates[default_currency.symbol.upcase.to_sym].rate_btc.to_f
      }
    end

    today_rates = ExchangeRate.today

    if today_rates.blank?
      ExchangeRate.create!(exchange_rates)
    else
      today_rates.each do |tr|
        tr.assign_attributes(exchange_rates.find { |er| 
          er[:from_currency] == tr.from_currency && er[:to_currency] == tr.to_currency
        })
        tr.save!
      end
    end
  end
end
