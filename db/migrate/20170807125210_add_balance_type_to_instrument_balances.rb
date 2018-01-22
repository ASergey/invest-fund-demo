class AddBalanceTypeToInstrumentBalances < ActiveRecord::Migration[5.1]
  def up
    execute <<-SQL
      CREATE TYPE instrument_type
      AS ENUM ('hashnest', 'bixin', 'default');
    SQL

    remove_column :instruments, :capitalization, :decimal, null: false, default: 0.0
    add_column    :instruments, :notes, :text, null: true
    add_column    :instruments, :instrument_type, :instrument_type, null: false, default: 'default'
    
    remove_reference :instrument_balances, :instrument, null: false
    add_reference    :instrument_balances, :instrument, index: true, foreign_key: { on_delete: :cascade }

    remove_column :instrument_balances, :amount, :decimal, null: false, default: 0.0
    add_column    :instrument_balances, :amount, :jsonb # { amount: 0.0 BTC(currency_id), custom_key: value, custom_key: value }
    add_column    :instrument_balances, :type, :string
  end

  def down
    remove_column :instrument_balances, :type, :string
    remove_column :instrument_balances, :amount, :jsonb
    add_column    :instrument_balances, :amount, :decimal, null: false, default: 0.0
    
    remove_reference :instrument_balances, :instrument, index: true, foreign_key: { on_delete: :cascade }
    add_reference    :instrument_balances, :instrument

    remove_column :instruments, :instrument_type
    remove_column :instruments, :notes, :text, null: true
    add_column    :instruments, :capitalization, :decimal, null: false, default: 0.0
   
    execute <<-SQL
      DROP TYPE instrument_type;
    SQL
  end
end
