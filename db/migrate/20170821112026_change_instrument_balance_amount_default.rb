class ChangeInstrumentBalanceAmountDefault < ActiveRecord::Migration[5.1]
  def change
    change_column_default :instrument_balances, :amount, {}
    change_column_null :instrument_balances, :amount, false
  end
end
