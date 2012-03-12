class AddApplicationDateToMembers < ActiveRecord::Migration
  def change
    add_column :members, :application_date, :date

  end
end
