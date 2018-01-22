class AddInvestorFieldsToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :phone,    :string
    add_column :users, :is_gp,    :boolean, null: false, default: false
    add_column :users, :is_lp,    :boolean, null: false, default: false
    add_column :users, :reinvest, :boolean, null: false, default: false

    rename_column      :kyc_documents, :second_name, :last_name
    remove_foreign_key :kyc_documents, :investors
    remove_column      :kyc_documents, :investor_id, :integer
    add_reference      :kyc_documents, :user, foreign_key: true, null: false

    remove_foreign_key :wallets, :investors
    remove_foreign_key :wallets, :currencies
    remove_column      :wallets, :investor_id, :integer
    remove_column      :wallets, :currency_id, :integer
    add_reference      :wallets, :user, foreign_key: true, null: false
    add_reference      :wallets, :currency, foreign_key: true, null: false

    remove_reference   :investor_reports,       :investor, index: true, foreign_key: true
    remove_reference   :management_fee_reports, :investor, index: true, foreign_key: true
    remove_reference   :interest_fee_reports,   :investor, index: true, foreign_key: true

    add_reference       :investor_reports,       :users, index: true, foreign_key: true, null: false
    add_reference       :management_fee_reports, :users, index: true, foreign_key: true, null: false
    add_reference       :interest_fee_reports,   :users, index: true, foreign_key: true, null: false

    drop_table         :investors
  end
end
