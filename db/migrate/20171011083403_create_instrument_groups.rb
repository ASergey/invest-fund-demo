class CreateInstrumentGroups < ActiveRecord::Migration[5.1]
  def change
    create_table :instrument_groups do |t|
      t.string :name
      t.text   :description

      t.timestamps
    end

    add_index :instrument_groups, :name, unique: true
    add_reference :instruments, :instrument_group
  end
end
