class AddStuffToMembers < ActiveRecord::Migration
  def change
    add_column :members, :application_exists, :boolean, :default => 0
    add_column :members, :join_date, :date
    add_column :members, :join_protocol, :string
    add_column :members, :card_number, :integer
  end
end
