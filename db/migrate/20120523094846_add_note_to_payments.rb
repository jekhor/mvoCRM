class AddNoteToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :note, :text

  end
end
