class RemoveSiteUserCreationDateFromMembers < ActiveRecord::Migration[6.0]
  def change
    remove_column :members, :site_user_creation_date
  end
end
