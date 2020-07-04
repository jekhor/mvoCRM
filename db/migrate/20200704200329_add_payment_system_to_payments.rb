class AddPaymentSystemToPayments < ActiveRecord::Migration[6.0]
  def change
    add_column :payments, :payment_system, :string
  end
end
