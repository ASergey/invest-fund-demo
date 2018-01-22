class CreateWallets < ActiveRecord::Migration[5.1]
  def change
    create_table :wallets do |t|
      t.string    :name
      t.string    :address, null: false
      t.integer   :investor_id
      t.integer   :currency_id

      t.timestamps
    end

    add_foreign_key :wallets, :investors, on_delete: :cascade
    add_foreign_key :wallets, :currencies, on_delete: :cascade
  end
end
