class MakeDatesNotRequiredInPayment < ActiveRecord::Migration[6.0]
  def change
    change_column :payments, :start_date, :date, null: true
    change_column :payments, :end_date, :date, null: true
  end
end
