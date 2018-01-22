class CreateExchangeOperations < ActiveRecord::Migration[5.1]
  def change
    create_table :exchange_operations do |t|
      t.references :user, null: false
      t.references :from_currency,
        null: false,  index: true, foreign_key: { to_table: :currencies, on_delete: :cascade }
      t.references :to_currency, null: false, index: true, foreign_key: { to_table: :currencies, on_delete: :cascade }
      t.references :fund_wallet_from, foreign_key: { to_table: :wallets, on_delete: :nullify }
      t.references :fund_wallet_to, foreign_key: { to_table: :wallets, on_delete: :nullify }
      t.decimal    :amount, null: false
      t.decimal    :result_amount, null: false
      t.references :exchange_rate, null: false, index: true, foreign_key: { on_delete: :cascade }
      t.datetime   :deleted_at

      t.timestamps
    end

    add_index :exchange_operations, :deleted_at
  end
end
