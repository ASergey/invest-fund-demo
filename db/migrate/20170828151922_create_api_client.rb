class CreateApiClient < ActiveRecord::Migration[5.1]
  def change
    create_table :api_clients do |t|
      t.string :name
      t.string :client_key
      t.text :notes

      t.timestamps
    end

    add_index(:api_clients, :client_key, unique: true)
  end
end
