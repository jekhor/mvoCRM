class Member < ActiveRecord::Base
  attr_accessible :given_names, :last_name, :date_of_birth, :address, :email, :phone

  validates :given_names, :presence => true,
                          :length => {:maximum => 50}
  validates :last_name, :presence => true,
                          :length => {:maximum => 50}
  validates :date_of_birth, :presence => true
  
  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

#  validates :email, :format => {:with => email_regex}
end
