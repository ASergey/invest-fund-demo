module InstrumentHashConcern
  extend ActiveSupport::Concern

  included do
    scope :by_hash_code, ->(hash_code) { where(hash_code: hash_code) }

    validates :hash_code, :hash_amount, :hash_rate, presence: true
    validates :hash_code, length: { maximum: 20 }
    validates :hash_amount, numericality: { only_integer: true }
    validates :hash_amount, :hash_rate, numericality: { greater_than_or_equal_to: 0 }
  end
end
