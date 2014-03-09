class AddMembershipPausedToMembers < ActiveRecord::Migration
  def change
    add_column :members, :membership_paused, :boolean
    add_column :members, :membership_pause_note, :text
  end
end
