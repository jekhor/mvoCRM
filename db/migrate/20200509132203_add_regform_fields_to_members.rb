class AddRegformFieldsToMembers < ActiveRecord::Migration[6.0]
  def change
    add_column :members, :photo_url, :string
    add_column :members, :subscribe_to_mails, :boolean, default: false
  end
end
