class RemoveInstrumentHashReportsReportDate < ActiveRecord::Migration[5.1]
  def change
    remove_column :instrument_hash_reports, :report_date, :date
  end
end
