class AddPostalAddressToMembers < ActiveRecord::Migration
  def change
    add_column :members, :postal_address, :string

  end
end
