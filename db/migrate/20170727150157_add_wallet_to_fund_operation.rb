class AddWalletToFundOperation < ActiveRecord::Migration[5.1]
  def change
    add_reference :fund_operations, :wallet, foreign_key: true
    add_reference :fund_operations, :kyc_document, foreign_key: true
  end
end
