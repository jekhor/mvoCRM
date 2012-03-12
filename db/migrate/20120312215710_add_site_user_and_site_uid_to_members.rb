class AddSiteUserAndSiteUidToMembers < ActiveRecord::Migration
  def change
    add_column :members, :site_user, :string

    add_column :members, :site_uid, :integer

    add_index :members, :site_uid, :unique => true
    add_index :members, :site_user, :unique => true
  end
end
