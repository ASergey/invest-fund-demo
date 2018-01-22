class InstrumentGroup < ApplicationRecord
  has_many :instruments

  validates :name, presence: true, uniqueness: true
  validates :description, length: { maximum: 1000 }, allow_blank: true
end
