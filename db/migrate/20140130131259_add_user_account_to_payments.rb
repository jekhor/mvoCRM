class AddUserAccountToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :user_account, :string
  end
end
