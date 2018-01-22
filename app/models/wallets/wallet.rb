class Wallet < ApplicationRecord
  acts_as_paranoid

  belongs_to :currency
  has_many :fund_operations, dependent: :nullify

  scope :fund_wallets, -> { where(user_id: nil) }

  validates :name, :address, :currency, presence: true
  validates :address, length: { maximum: 500 },
            uniqueness: {
              case_sensitive: false,
              scope: :currency_id
            }
  validates :name, length: { maximum: 100 }
  validates :currency, inclusion: { in: proc { Currency.all } }

  def self.fund_wallets_options
    select(:id, :name, :currency_id).fund_wallets.includes(:currency).collect { |w| [w.name + ' - ' + w.currency.symbol, w.id] }
  end
end
