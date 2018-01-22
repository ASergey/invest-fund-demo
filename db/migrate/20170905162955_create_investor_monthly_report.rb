class CreateInvestorMonthlyReport < ActiveRecord::Migration[5.1]
  def change
    create_table :investor_monthly_reports do |t|
      t.references :user, index: true, foreign_key: true, null: false
      t.decimal    :dividend_amount, null: false, default: 0.0
      t.decimal    :management_fee, null: false, default: 0.0
      t.decimal    :carried_interest_fee, null: false, default: 0.0
      t.decimal    :payout_amount, null: false, default: 0.0
      t.references :currency, null: false
      t.date       :report_date, null: false, default: { expr: "('now'::text)::date" }
      t.timestamps
    end

    change_column_null :fund_operations, :user_id, true
  end
end
