class CreateDonations < ActiveRecord::Migration
  def change
    create_table :donations do |t|
      t.date :date
      t.string :document_number
      t.integer :amount
      t.string :donor
      t.text :note

      t.timestamps
    end
  end
end
