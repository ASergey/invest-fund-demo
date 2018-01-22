class RemoveUniqueIndexFromInstrumentReports < ActiveRecord::Migration[5.1]
  def change
    remove_index :instrument_reports, %i[instrument_id currency_id]
  end
end
