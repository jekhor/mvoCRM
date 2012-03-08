# == Schema Information
#
# Table name: members
#
#  id                 :integer         not null, primary key
#  given_names        :string(255)
#  last_name          :string(255)
#  date_of_birth      :date
#  address            :string(255)
#  email              :string(255)
#  phone              :string(255)
#  created_at         :datetime        not null
#  updated_at         :datetime        not null
#  application_exists :boolean         default(FALSE)
#  join_date          :date
#  join_protocol      :string(255)
#  card_number        :integer
#  joined             :boolean
#

class Member < ActiveRecord::Base
  attr_accessible :given_names, :last_name, :date_of_birth, :address, :email, :phone
  attr_accessible :application_exists, :join_date, :join_protocol, :card_number, :joined

  validates :given_names, :presence => true,
                          :length => {:maximum => 50}
  validates :last_name, :presence => true,
                          :length => {:maximum => 50}
  validates :date_of_birth, :presence => true

  validates :join_protocol, :presence => {:if => :joined}
  validates :join_date, :presence => {:if => :joined}

#  validates_each :join_protocol, :join_date do |record, attr, value|
#    record.errors.add attr, 'is not empty' if !value.nil? and !record.joined
#    record.errors.add attr, 'is empty' if value.nil? and record.joined
#  end

  validates :card_number, :inclusion => {:in => 0..999999, :allow_nil => true}

  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  validates :email, :format => {:with => email_regex, :allow_nil => true}

end
