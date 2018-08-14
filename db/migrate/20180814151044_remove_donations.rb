class RemoveDonations < ActiveRecord::Migration[5.2]
  def change
    drop_table :donations do |t|
      t.datetime :datetime
      t.string :document_number
      t.integer :amount
      t.string :donor
      t.text :note
      t.integer :payment_id, default: 0, null: false
      t.index ["payment_id"], name: "index_donations_on_payment_id", unique: true

      t.timestamps
    end
  end
end
