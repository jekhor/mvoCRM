class ChangeAmountInPayments < ActiveRecord::Migration
  def change
    change_column :payments, :amount, :decimal, :precision => 10, :scale => 2
  end
end
