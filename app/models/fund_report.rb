class FundReport < ApplicationRecord
  include DefaultCurrencyExchangeConcern
  include ReportConcern

  belongs_to :currency, -> { with_deleted }

  def self.capitalization_before_date(date)
    report = by_report_date(date - 1.day).first
    report.present? ? report.capitalization : nil
  end

  def self.capitalization_by_date(date)
    report = by_report_date(date).first
    report.present? ? report.capitalization : nil
  end
end
