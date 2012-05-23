class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.integer :member_id
      t.date :date, :null => false
      t.decimal :amount, :precision => 2, :null => false
      t.date :start_date, :null => false
      t.date :end_date, :null => false

      t.timestamps
    end
  end
end
