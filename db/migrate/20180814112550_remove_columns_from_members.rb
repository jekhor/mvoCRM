class RemoveColumnsFromMembers < ActiveRecord::Migration
  def change
    [:application_exists, :join_protocol, :joined,
     :application_date].each {|c|
      remove_column :members, c
    }
  end
end
