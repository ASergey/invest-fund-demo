class CreateCurrencies < ActiveRecord::Migration[5.1]
  def change
    create_table :currencies do |t|
      t.string    :name
      t.string    :symbol

      t.datetime  :created_at
    end
  end
end
