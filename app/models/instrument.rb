class Instrument < ApplicationRecord
  extend Enumerize

  INSTRUMENT_TYPE_BIXIN    = 'bixin'.freeze
  INSTRUMENT_TYPE_DEFAULT  = 'default'.freeze
  INSTRUMENT_TYPE_HASHNEST = 'hashnest'.freeze

  enumerize  :instrument_type, in: %i[default hashnest bixin], default: :default, scope: true
  has_many   :instrument_balances, dependent: :restrict_with_error
  has_many   :instrument_reports, dependent: :restrict_with_error
  has_many   :fund_operations, dependent: :restrict_with_error
  belongs_to :instrument_group, optional: true

  validates :name, :instrument_type, presence: true
  validates :name, length: { minimum: 2 }
  validates :instrument_type, inclusion: { in: Instrument.instrument_type.values }

  def capitalization
    cap = 0.0
    instrument_balances.each do |balance|
      cap += ExchangeRate.convert_to_default(balance.total_balance, balance.currency)
    end
    cap
  end

  def self.total_capitalization
    Instrument.all.map(&:capitalization).sum
  end
end
