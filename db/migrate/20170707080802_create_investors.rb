class CreateInvestors < ActiveRecord::Migration[5.1]
  def change
    create_table :investors do |t|
      t.string  :phone
      t.boolean :is_gp, default: false
      t.boolean :is_lp, default: false
      t.boolean :dividend_payment, default: false
      t.integer :user_id

      t.timestamps
    end
  end
end
