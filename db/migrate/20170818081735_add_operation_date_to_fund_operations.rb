class AddOperationDateToFundOperations < ActiveRecord::Migration[5.1]
  def change
    add_column :fund_operations, :operation_date, :date, null: false, default: Date.today
    change_column_default :fund_operations, :operation_date, nil
  end
end
