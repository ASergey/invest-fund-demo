class FundBalance < ApplicationRecord
  include DefaultCurrencyExchangeConcern
  include FundBalanceConcern

  validates :currency, uniqueness: true

  def self.capitalization
    FundBalance.all.map(&:amount_to_default).sum
  end

  def self.total_capitalization
    FundBalance.capitalization + Instrument.total_capitalization
  end
end
