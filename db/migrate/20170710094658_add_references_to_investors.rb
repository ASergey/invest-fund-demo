class AddReferencesToInvestors < ActiveRecord::Migration[5.1]
  def change
    add_foreign_key :investors, :users
    add_index :investors, :user_id
  end
end
