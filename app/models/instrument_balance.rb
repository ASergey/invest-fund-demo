class InstrumentBalance < ApplicationRecord
  include InstrumentConcern
  include DefaultCurrencyExchangeConcern

  has_many  :instrument_hash_balances, dependent: :destroy

  validates :currency, uniqueness: { scope: :instrument_id }

  accepts_nested_attributes_for :instrument_hash_balances

  def total_balance
    total = amount
    instrument_hash_balances.each do |hash_balace|
      total += hash_balace.hash_amount * hash_balace.hash_rate
    end
    total
  end

  def build_hash_report(last_day_report = nil)
    return unless instrument_hash_balances.count.positive?

    hash_report_params = []
    instrument_hash_balances.each do |hash_balance|
      hash_params = {
        hash_amount: hash_balance.hash_amount,
        hash_rate:   hash_balance.hash_rate,
        hash_code:   hash_balance.hash_code
      }
      if last_day_report.present? && last_day_report.instrument_hash_reports.present?
        last_day_hash_report = last_day_report.instrument_hash_reports
                                              .fetch_by_hash_code(last_day_report.id, hash_balance.hash_code)
        hash_params[:id] = last_day_hash_report.id if last_day_hash_report.present?
      end
      hash_report_params << hash_params
    end
    hash_report_params
  end
end
