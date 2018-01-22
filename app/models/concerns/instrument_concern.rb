module InstrumentConcern
  extend ActiveSupport::Concern

  included do
    belongs_to :instrument
    belongs_to :currency

    scope :by_instrument, ->(instrument_id) { where(instrument_id: instrument_id) }

    validates :instrument, :amount, :currency, presence: true
    validates :amount, numericality: true
  end
end
