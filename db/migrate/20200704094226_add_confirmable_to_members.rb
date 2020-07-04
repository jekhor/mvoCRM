class AddConfirmableToMembers < ActiveRecord::Migration[6.0]
  def up
    add_column :members, :confirmation_token, :string
    add_column :members, :confirmed_at, :datetime
    add_column :members, :confirmation_sent_at, :datetime
    # add_column :members, :unconfirmed_email, :string # Only if using reconfirmable
    add_index :members, :confirmation_token, unique: true
    # User.reset_column_information # Need for some types of updates, but not for update_all.
    # To avoid a short time window between running the migration and updating all existing
    # members as confirmed, do the following
    Member.update_all confirmed_at: DateTime.now
    # All existing user accounts should be able to log in after this.
  end

  def down
    remove_columns :members, :confirmation_token, :confirmed_at, :confirmation_sent_at
    # remove_columns :members, :unconfirmed_email # Only if using reconfirmable
  end
end
