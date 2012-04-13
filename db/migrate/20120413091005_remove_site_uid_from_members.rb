class RemoveSiteUidFromMembers < ActiveRecord::Migration
  def change
    remove_column :members, :site_uid
  end
end
