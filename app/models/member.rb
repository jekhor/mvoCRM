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

  has_many :payments

  attr_accessible :given_names, :last_name, :date_of_birth, :address, :email, :phone
  attr_accessible :application_exists, :join_date, :join_protocol, :card_number, :joined
  attr_accessible :postal_address, :application_date, :site_user, :site_user_creation_date

  validates :given_names, :presence => true,
                          :length => {:maximum => 50}
  validates :last_name, :presence => true,
                          :length => {:maximum => 50}
#  validates :date_of_birth, :presence => true

  validates :join_protocol, :presence => {:if => :joined}
  validates :join_date, :presence => {:if => :joined}

  validates :application_date, :presence => {:if => :application_exists}
#  validates_each :join_protocol, :join_date do |record, attr, value|
#    record.errors.add attr, 'is not empty' if !value.nil? and !record.joined
#    record.errors.add attr, 'is empty' if value.nil? and record.joined
#  end

  validates :card_number, :inclusion => {:in => 1..999999, :allow_nil => true}

  email_regex = /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+\z/

  validates :email, :format => {:with => email_regex, :allow_blank => true},
                    :uniqueness => {:case_sensitive => false, :allow_nil => true}

  validates :site_user, :uniqueness => {:allow_nil => true}

  before_validation :set_nil
  before_save :set_nil

  comma do
    last_name
    given_names
    date_of_birth
    address
    postal_address
    email
    phone
    application_exists
    application_date
    join_date
    join_protocol
    card_number
    joined
    site_user
    site_user_creation_date
    debtor?
    last_payment_date
    last_payment_amount
  end

  def self.search(search)
    if search
      where('last_name LIKE ? OR card_number = ?', "#{Unicode::capitalize(search)}%", search.to_i)
    else
      scoped
    end
  end

  def site_user_normalized
    tmp = site_user.gsub(/[_.]/, "")
  end

  def full_name
    self.last_name + " " + self.given_names
  end

  def first_name
    self.given_names.split(/\s/, 2)[0]
  end

  def card_number_str
    unless self.card_number.nil?
      sprintf("%06d", self.card_number)
    else
      ''
    end
  end

  def debtor?
    p = self.payments.find(:last,
                             :conditions => {:end_date => Time.now.to_date..('9999-01-01'.to_date) })
    p.nil?
  end

  def last_payment_date
    p = self.payments.find(:last)
    if p.nil?
      nil
    else
      p.date
    end
  end

  def last_payment_amount
    p = self.payments.find(:last)
    if p.nil?
      nil
    else
      p.amount
    end

  end

  private

  def set_nil
    self[:email] = nil if self[:email].blank?
  end

end
