class ChangeDateToDatetimeInDonations < ActiveRecord::Migration
  def change
    remove_column :donations, :date
    add_column :donations, :datetime, :datetime
  end
end
