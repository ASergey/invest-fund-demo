module DefaultCurrencyExchangeConcern
  extend ActiveSupport::Concern

  def amount_to_default(date = nil)
    ExchangeRate.convert_to_default(amount, currency, date)
  end
end
