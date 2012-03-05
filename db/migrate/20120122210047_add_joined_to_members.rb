class AddJoinedToMembers < ActiveRecord::Migration
  def change
    add_column :members, :joined, :boolean

  end
end
