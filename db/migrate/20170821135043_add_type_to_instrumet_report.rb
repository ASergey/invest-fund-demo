class AddTypeToInstrumetReport < ActiveRecord::Migration[5.1]
  def change
    add_column    :instrument_reports, :type, :string
    remove_column :instrument_reports, :capitalisation, null: false, default: 0.0
    
    change_column_default :instrument_reports, :amount, nil

    change_column :instrument_reports, :amount, 'varchar USING CAST(amount AS varchar)'
    change_column :instrument_reports, :amount, 'jsonb USING CAST(amount AS jsonb)', null: false, default: {}
    add_index     :instrument_reports, :amount, using: :gin

    add_column    :instrument_reports, :report_date, :date, null: false, default: Date.today
    add_index     :instrument_reports, :report_date, order: { report_date: 'DESC NULLS LAST' }
    
    change_column_default :instrument_reports, :report_date, "NOW()"
  end
end
