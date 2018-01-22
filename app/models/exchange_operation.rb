class ExchangeOperation < ApplicationRecord
  acts_as_paranoid

  belongs_to :user, -> { with_deleted }
  belongs_to :exchange_rate

  belongs_to :from_currency, class_name: 'Currency', foreign_key: 'from_currency_id'
  belongs_to :to_currency, class_name: 'Currency', foreign_key: 'to_currency_id'
  belongs_to :fund_wallet_from, class_name: 'Wallet', foreign_key: 'fund_wallet_from_id'
  belongs_to :fund_wallet_to, class_name: 'Wallet', foreign_key: 'fund_wallet_to_id'

  around_save :calc_fund_balance
  before_validation :calc_result_amount

  validates :user, :exchange_rate, :from_currency, :to_currency, :amount, :result_amount, presence: true
  validates :from_currency, :to_currency, inclusion: { in: proc { Currency.all } }
  validates :fund_wallet_from, :fund_wallet_to, inclusion: { in: proc { Wallet.all } }, allow_blank: true
  validates :amount, :result_amount, numericality: { greater_than_or_equal_to: 0 }

  attr_reader :rate

  def calc_fund_balance
    yield
    # TODO undo fund calculations if marked as deleted
  end

  def calc_result_amount
    return unless from_currency.present? && to_currency.present?

    rate = ExchangeRate.rate_to_currency(from_currency.id, to_currency.id)
    return if rate.blank?

    result_amount = rate.rate * amount
  end
end
