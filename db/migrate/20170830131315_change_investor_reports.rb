class ChangeInvestorReports < ActiveRecord::Migration[5.1]
  def change
    remove_reference :investor_reports, :users, index: true, foreign_key: true, null: false
    add_reference    :investor_reports, :user, index: true, foreign_key: true, null: false

    add_column :currencies, :default, :boolean, default: false
    Currency.where(symbol: 'USD').update(default: true)

    ActiveRecord::Base.connection.execute('TRUNCATE exchange_rates RESTART IDENTITY')

    remove_column :exchange_rates, :created_at, :datetime
    add_timestamps :exchange_rates

    rename_column         :fund_reports, :total, :total_invested
    rename_column         :fund_reports, :capitalisation, :capitalization
    add_column            :fund_reports, :report_date, :date, null: false, default: Date.today
    add_index             :fund_reports, :report_date, order: { report_date: 'DESC' }
    change_column_default :fund_reports, :report_date, from: Date.today, to: { expr: "('now'::text)::date" }

    create_table :fund_balance_reports do |t|
      t.references :currency,       null: false
      t.decimal    :amount,         null: false, default: 0.0
      t.date       :report_date,    null: false, default: { expr: "('now'::text)::date" }
      t.timestamps
    end

    add_index :fund_balance_reports, :report_date, order: { report_date: 'DESC' }

    rename_column         :investor_reports, :capitalisation, :capitalization
    rename_column         :investor_reports, :initial, :amount
    remove_column         :investor_reports, :created_at, :datetime
    add_timestamps        :investor_reports
    add_column            :investor_reports, :report_date, :date, null: false, default: { expr: "('now'::text)::date" }
    change_column_default :instrument_reports, :report_date, { expr: "('now'::text)::date" }
    add_reference         :investor_reports, :currency, index: true, foreign_key: true, null: false
    
    rename_column      :investor_balances, :investor_id, :user_id
  end
end
