class ChangeUserExchangeTables < ActiveRecord::Migration[5.1]
  def change
    rename_column :exchange_rates, :value, :rate

    add_column :fund_operations, :deleted_at, :datetime
    add_index :fund_operations, :deleted_at

    add_column :users, :deleted_at, :datetime
    add_index :users, :deleted_at

    remove_foreign_key :fund_operations, :investors
    add_foreign_key    :fund_operations, :users, column: :investor_id

    remove_foreign_key :investor_balances, :investors
    add_foreign_key    :investor_balances, :users, column: :investor_id
  end
end
