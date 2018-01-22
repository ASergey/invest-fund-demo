class InstrumentReport < ApplicationRecord
  include InstrumentConcern
  include ReportConcern

  has_many  :instrument_hash_reports, dependent: :destroy
  has_many :instrument_group, through: :instrument

  validates :currency, uniqueness: { scope: %i[instrument_id report_date] }

  accepts_nested_attributes_for :instrument_hash_reports

  def total_balance
    total = amount
    instrument_hash_reports.each do |hash_report|
      total += hash_report.hash_amount * hash_report.hash_rate
    end
    total
  end

  def hash_reports_data_list
    return nil if instrument_hash_reports.blank?
    instrument_hash_reports.map do |hash_report|
      hash_report.attributes.symbolize_keys.extract!(:hash_code, :hash_amount, :hash_rate)
    end
  end

  def self.last_day_report(currency_id, instrument_id)
    by_report_date(1.day.ago.to_date).by_currency(currency_id).by_instrument(instrument_id).first
  end

  def self.total_capitalization(date)
    cap = 0.0
    by_report_date(date).each do |report|
      cap += ExchangeRate.convert_to_default(report.total_balance, report.currency, date)
    end
    cap
  end

  def self.grouped_daily_reports
    select(
      'SUM(instrument_reports.amount) as sum_amount,
      instrument_reports.report_date,
      instrument_reports.currency_id,
      currencies.symbol,
      instrument_groups.name as group_name'
    )
    .joins(:currency, instrument: :instrument_group)
    .order(report_date: :desc)
    .group(:currency_id, :report_date, 'currencies.symbol', 'instrument_groups.name')
  end
end
