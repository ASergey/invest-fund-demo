class ExchangeRate < ApplicationRecord
  belongs_to :from_currency, class_name: 'Currency', foreign_key: 'currency_id'
  belongs_to :to_currency, class_name: 'Currency', foreign_key: 'to_currency_id'

  scope :today, -> { where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day) }
  scope :rate_to_default, ->(currency_id) {
    where(from_currency: currency_id, to_currency: Currency.default).order(created_at: :desc)
  }
  scope :by_date, ->(date) { where('created_at::date = ?', date) }

  def self.convert_to_default(amount, currency, date = nil)
    return amount if currency.default?

    exchange_rate = rate_to_default(currency).first if date.blank? || date == Date.current
    exchange_rate = by_date(date).rate_to_default(currency).first if date.present?

    raise I18n.t('report.exchange_rate_error', currency: currency.symbol, date: date) if exchange_rate.blank?

    amount * exchange_rate.rate
  end

  def self.rate_to_currency(currency, to_currency)
    return { rate: 1.0 } if currency == to_currency

    result = where(from_currency: currency, to_currency: to_currency).order(created_at: :desc).first
    result = { rate: rate_through_default(currency, to_currency) } if result.blank?
    result
  end

  def self.rate_through_default(currency, to_currency)
    currency    = Currency.find(currency)
    to_currency = Currency.find(to_currency)

    return nil unless [currency, to_currency].all?(&:present?)

    from_rate = currency.default? ? { rate: 1.0 } : rate_to_default(currency).first
    to_rate   = to_currency.default? ? { rate: 1.0 } : rate_to_default(to_currency).first

    return nil unless [from_rate, to_rate].all?(&:present?)
    from_rate[:rate] / to_rate[:rate]
  end
end
