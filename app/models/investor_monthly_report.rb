class InvestorMonthlyReport < ApplicationRecord
  belongs_to :currency
  belongs_to :user, -> { with_deleted }, optional: true

  scope :by_investor, ->(investor_id) { where(user_id: investor_id) }

  validates :user, :dividend_amount, :management_fee, :currency, :report_date, presence: true
  validates :dividend_amount, :management_fee, :carried_interest_fee, numericality: true
  validates :user, uniqueness: { scope: %i[report_date currency_id] }
  validates_date :report_date, allow_blank: false
end
