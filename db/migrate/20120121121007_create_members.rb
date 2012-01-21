class CreateMembers < ActiveRecord::Migration
  def change
    create_table :members do |t|
      t.string :given_names
      t.string :last_name
      t.date :date_of_birth
      t.string :address
      t.string :email
      t.string :phone

      t.timestamps
    end
  end
end
