class AddTypeToWallets < ActiveRecord::Migration[5.1]
  def change
    add_column :wallets, :type, :string
    add_column :wallets, :deleted_at, :datetime
    add_index  :wallets, :deleted_at

    change_column_null :wallets, :user_id, true

    remove_foreign_key :wallets, :users
    remove_foreign_key :wallets, :currencies

    add_foreign_key :wallets, :users, foreign_key: { on_delete: :cascade }
    add_foreign_key :wallets, :currencies, foreign_key: { on_delete: :cascade }

    Wallet.where.not(user_id: nil).update_all(type: 'InvestorWallet')
  end
end
