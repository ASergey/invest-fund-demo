class CreateFundTables < ActiveRecord::Migration[5.1]
  def change
    execute <<-SQL
      CREATE TYPE fund_operations_type
      AS ENUM ('investment', 'payout', 'interest_fee', 'management_fee', 'exchange');

      CREATE TYPE fund_operations_status
      AS ENUM ('done', 'pending', 'canceled');
    SQL

    # free fund money
    create_table :fund_balances do |t|
      t.references :currency,       null: false
      t.decimal    :amount,         null: false, default: 0.0

      t.timestamps
    end

    add_foreign_key :fund_balances, :currencies, column: :currency_id

    # daily fund reports
    create_table :fund_reports do |t|
      t.decimal    :total,          null: false, default: 0.0
      t.decimal    :capitalisation, null: false, default: 0.0 # TODO: rename to capitalization
      t.decimal    :daily_invested, null: false, default: 0.0
      t.decimal    :total_fees,     null: false, default: 0.0 # not yet payed out fees by the created_at date
      t.references :currency,       null: false
      t.datetime   :created_at,     null: false
    end

    add_foreign_key :fund_reports, :currencies, column: :currency_id

    create_table :instruments do |t|
      t.string  :name,           null: false
      t.decimal :capitalization, null: false, default: 0.0

      t.timestamps
    end

    create_table :instrument_balances do |t|
      t.references :instrument,     null: false
      t.decimal    :amount,         null: false, default: 0.0
      t.references :currency,       null: false

      t.timestamps
    end

    add_foreign_key :instrument_balances, :currencies, column: :currency_id
    add_foreign_key :instrument_balances, :instruments, column: :instrument_id

    # daily instrument report
    create_table :instrument_reports do |t|
      t.references :instrument,     null: false
      t.references :currency,       null: false
      t.decimal    :amount,         null: false, default: 0.0
      t.decimal    :capitalisation, null: false, default: 0.0
      t.datetime   :created_at,     null: false
    end

    add_foreign_key :instrument_reports, :instruments, column: :instrument_id
    add_foreign_key :instrument_reports, :currencies, column: :currency_id

    create_table :investor_balances do |t|
      t.references :investor,       null: false
      t.decimal    :amount,         null: false, default: 0.0
      t.references :currency,       null: false

      t.timestamps
    end

    add_foreign_key :investor_balances, :currencies, column: :currency_id
    add_foreign_key :investor_balances, :investors, column: :investor_id

    create_table :investor_reports do |t|
      t.references :investor,        null: false
      t.decimal    :initial,         null: false
      t.decimal    :capitalisation,  null: false
      t.decimal    :daily_revenue,   null: false
      t.decimal    :daily_profit,    null: false
      t.datetime   :created_at,      null: false
    end

    add_foreign_key :investor_reports, :investors, column: :investor_id
    create_table :management_fee_reports do |t|
      t.references :investor,       null: false
      t.decimal    :amount,         null: false, default: 0.0
      t.decimal    :percent,        precision: 8, scale: 5
      t.datetime   :created_at,     null: false
    end

    add_foreign_key :management_fee_reports, :investors, column: :investor_id

    create_table :interest_fee_reports do |t|
      t.references :investor,       null: false
      t.decimal    :amount,         null: false, default: 0.0
      t.decimal    :percent,        precision: 8, scale: 5
      t.datetime   :created_at,     null: false
    end

    add_foreign_key :interest_fee_reports, :investors, column: :investor_id

    # financial tasks
    create_table :fund_operations do |t|
      t.references :user,           null: false # manager
      t.references :investor,       null: true
      t.references :instrument,     null: true
      t.decimal    :amount,         null: false, default: 0.0
      t.references :currency,       null: false
      t.text       :notes

      t.column     :operation_type, :fund_operations_type,   null: false, default: 'investment'
      t.column     :status,         :fund_operations_status, null: false, default: 'pending'

      t.timestamps
    end

    add_foreign_key :fund_operations, :currencies, column: :currency_id
    add_foreign_key :fund_operations, :users, column: :user_id
    add_foreign_key :fund_operations, :investors, column: :investor_id
    add_foreign_key :fund_operations, :instruments, column: :instrument_id
  end
end
