class CreateInstrumentHashBalance < ActiveRecord::Migration[5.1]
  def change
    create_table :instrument_hash_balances do |t|
      t.references :instrument_balance, null: false, foreign_key: { on_delete: :cascade }
      t.string  :hash_code, null: false
      t.integer :hash_amount, null: false, default: 0
      t.decimal :hash_rate, null: false, default: 0.0

      t.timestamps
    end

    create_table :instrument_hash_reports do |t|
      t.references :instrument_report, null: false, foreign_key: { on_delete: :nullify }
      t.string  :hash_code, null: false
      t.integer :hash_amount, null: false, default: 0
      t.decimal :hash_rate, null: false, default: 0.0
      t.date    :report_date, null: false, default: 'CURRENT_TIMESTAMP'

      t.timestamps
    end

    add_index :instrument_hash_balances, %i[instrument_balance_id hash_code], unique: true, name: 'instrument_hash_balance__instrument_balance__hash_code_idx'
    add_index :instrument_hash_reports, :report_date, order: { report_date: 'DESC NULLS LAST' }

    change_table :instrument_balances do |t|
      t.remove  :amount, :type
      t.decimal :amount, null: false, default: 0.0
    end

    change_table :instrument_reports do |t|
      t.remove  :amount, :type
      t.decimal :amount, null: false, default: 0.0
    end
  end
end
