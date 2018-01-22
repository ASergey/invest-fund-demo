class Currency < ApplicationRecord
  acts_as_paranoid

  before_commit :upcase_symbol

  has_many :wallets, dependent: :restrict_with_error
  has_many :fund_balances, dependent: :restrict_with_error
  has_many :fund_operations, dependent: :restrict_with_error
  has_many :exchange_rates, dependent: :restrict_with_error
  has_many :exchange_operations

  validates :name, :symbol, presence: true
  validates :name, length: { maximum: 500 }
  validates :symbol, length: { maximum: 10 }, uniqueness: true
  validates :default, uniqueness: true, if: :default?

  def self.select_options
    select(:id, :symbol, :name).collect { |c| [c.name + ' - ' + c.symbol, c.id] }
  end

  def self.default
    find_by!(default: true)
  end

  private

  def upcase_symbol
    symbol.upcase
  end
end
