class FundBalanceReport < ApplicationRecord
  include DefaultCurrencyExchangeConcern
  include FundBalanceConcern
  include ReportConcern

  validates :currency, uniqueness: { scope: %i[report_date] }

  def self.capitalization(date)
    all.by_report_date(date).map(&:amount_to_default).sum
  end

  def self.total_capitalization(date)
    capitalization(date) + InstrumentReport.total_capitalization(date)
  end
end
