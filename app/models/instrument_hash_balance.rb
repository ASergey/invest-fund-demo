class InstrumentHashBalance < ApplicationRecord
  include InstrumentHashConcern

  belongs_to :instrument_balance

  scope :by_instrument_balance, ->(balance_id) { where(instrument_balance_id: balance_id) }
  
  validates :hash_code, uniqueness: { scope: :instrument_balance_id, case_sensitive: false }
end
