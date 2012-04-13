class AddSiteUserCreationDateToMembers < ActiveRecord::Migration
  def change
    add_column :members, :site_user_creation_date, :date

  end
end
