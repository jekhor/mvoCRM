class FixupMembersJoinDate < ActiveRecord::Migration[6.0]
  def up
    Member.all.each do |m|
      unless m.site_user_creation_date.blank?
        if m.join_date.blank? or m.join_date > m.site_user_creation_date
          m.join_date = m.site_user_creation_date
          m.save!
        end
      end
    end
  end
end
