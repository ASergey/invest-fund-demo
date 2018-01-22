class AddDeletedAtToCurrencies < ActiveRecord::Migration[5.1]
  def change
    add_column :currencies, :deleted_at, :datetime
    add_index :currencies, :deleted_at
  end
end
