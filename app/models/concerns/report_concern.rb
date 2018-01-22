module ReportConcern
  extend ActiveSupport::Concern

  included do
    scope :by_report_date, ->(report_date) { where(report_date: report_date) }
    scope :by_currency,    ->(currency_id) { where(currency_id: currency_id) }
    scope :later_than,     ->(date)        { where('report_date >= ?', date).order(report_date: :asc) }

    validates_date :report_date, allow_blank: false, on_or_before: lambda { Date.current }

    def self.today_report(currency_id)
      by_report_date(Date.current).by_currency(currency_id).first
    end

    def self.last_day_report(currency_id)
      by_report_date(1.day.ago.to_date).by_currency(currency_id).first
    end
  end
end
