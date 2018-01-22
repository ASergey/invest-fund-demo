module FundBalanceConcern
  extend ActiveSupport::Concern

  included do
    belongs_to :currency

    scope :by_currency, ->(currency_id) { where(currency_id: currency_id) }

    validates :amount, :currency, presence: true
    validates :amount, numericality: { greater_than_or_equal_to: 0 }
    validates :currency, inclusion: { in: proc{ Currency.all } }
  end
end
