class ApiClient < ApplicationRecord
  validates :client_key, presence: true, length: { is: 128 }, uniqueness: true
  validates :name, presence: true, length: { maximum: 500 }
end
