class AddFundWalletsToFundOperations < ActiveRecord::Migration[5.1]
  def change
    remove_foreign_key :fund_operations, :wallets
    remove_foreign_key :fund_operations, :kyc_documents

    add_foreign_key :fund_operations, :wallets, foreign_key: { on_delete: :nullify }
    add_foreign_key :fund_operations, :kyc_documents, foreign_key: { on_delete: :nullify }

    add_reference :fund_operations, :fund_wallet_to, foreign_key: { to_table: :wallets, on_delete: :nullify }
    add_reference :fund_operations, :fund_wallet_from, foreign_key: { to_table: :wallets, on_delete: :nullify }
  end
end
