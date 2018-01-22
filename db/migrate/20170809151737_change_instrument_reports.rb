class ChangeInstrumentReports < ActiveRecord::Migration[5.1]
  def change
    remove_reference :instrument_reports, :instrument, null: false
    add_reference    :instrument_reports, :instrument, null: false, foreign_key: { on_delete: :cascade }

    remove_reference :instrument_reports, :currency, null: false
    add_reference    :instrument_reports, :currency, null: false, foreign_key: { on_delete: :cascade }

    add_index        :instrument_reports, %i[instrument_id currency_id], unique: true
  end
end
