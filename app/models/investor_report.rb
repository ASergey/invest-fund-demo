class InvestorReport < ApplicationRecord
  include ReportConcern

  belongs_to :currency
  belongs_to :user, -> { with_deleted }, optional: true

  scope :by_investor, ->(investor_id) { where(user_id: investor_id) }

  validates :user, :amount, :currency, presence: true
  validates :amount, numericality: true
  validates :user, uniqueness: { scope: %i[report_date currency_id] }

  def self.today_report(investor_id)
    by_report_date(Date.current).find_by(user_id: investor_id)
  end

  def self.by_date_report(investor_id, date)
    by_report_date(date).find_by(user_id: investor_id)
  end

  def self.capitalization_before_date(investor_id, date)
    report = InvestorReport.by_date_report(investor_id, date.to_date - 1.day)
    report.present? ? report.capitalization : nil
  end

  def self.profit_before_date(investor_id, date)
    report = InvestorReport.by_date_report(investor_id, date.to_date - 1.day)
    report.present? ? report.daily_profit : nil
  end

  def self.monthly_profit(investor_id, date)
    date = date.to_date
    InvestorReport.by_investor(investor_id)
                  .where(report_date: date.beginning_of_month..date.end_of_month).sum(:daily_profit)
  end
end
