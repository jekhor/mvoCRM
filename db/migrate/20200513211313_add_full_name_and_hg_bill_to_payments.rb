class AddFullNameAndHgBillToPayments < ActiveRecord::Migration[6.0]
  def change
    add_column :payments, :full_name, :string
    add_column :payments, :hg_bill, :json
  end
end
