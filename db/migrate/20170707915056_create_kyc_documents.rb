class CreateKycDocuments < ActiveRecord::Migration[5.1]
  def change
    create_table :kyc_documents do |t|
      t.string  :first_name
      t.string  :second_name
      t.string  :address
      t.integer :investor_id

      t.timestamps
    end

    add_foreign_key :kyc_documents, :investors
  end
end
