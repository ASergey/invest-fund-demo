class KycDocument < ApplicationRecord
  belongs_to :user

  validates :first_name, :last_name, :address, :user, presence: true
  validates :first_name, length: { minimum: 2 }
  validates :last_name, length: { minimum: 2 }
  validates :address, length: { maximum: 500 }
end
