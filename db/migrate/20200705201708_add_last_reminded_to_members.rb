class AddLastRemindedToMembers < ActiveRecord::Migration[6.0]
  def change
    add_column :members, :last_reminded, :date
  end
end
