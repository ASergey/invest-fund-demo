class CreateExchangeRates < ActiveRecord::Migration[5.1]
  def change
    create_table :exchange_rates do |t|
      t.integer   :currency_id
      t.integer   :to_currency_id
      t.decimal   :value

      t.datetime  :created_at
    end

    add_foreign_key :exchange_rates, :currencies, column: :currency_id, on_delete: :cascade
    add_foreign_key :exchange_rates, :currencies, column: :to_currency_id, on_delete: :cascade
  end
end
