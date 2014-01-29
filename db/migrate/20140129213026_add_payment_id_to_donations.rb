class AddPaymentIdToDonations < ActiveRecord::Migration
  def change
    add_column :donations, :payment_id, :integer, null: false, default: 0
    add_index :donations, :payment_id, unique: true
  end
end
