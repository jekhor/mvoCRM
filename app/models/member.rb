# == Schema Information
#
# Table name: members
#
#  id                     :integer          not null, primary key
#  address                :string(255)
#  card_number            :integer
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :string
#  date_of_birth          :date
#  email                  :string(255)
#  encrypted_password     :string           default(""), not null
#  given_names            :string(255)
#  join_date              :date
#  last_name              :string(255)
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :string
#  membership_pause_note  :text
#  membership_paused      :boolean
#  phone                  :string(255)
#  photo_url              :string
#  postal_address         :string(255)
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  sign_in_count          :integer          default(0), not null
#  site_user              :string(255)
#  subscribe_to_mails     :boolean          default(FALSE)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_members_on_email                 (email) UNIQUE
#  index_members_on_reset_password_token  (reset_password_token) UNIQUE
#  index_members_on_site_user             (site_user) UNIQUE
#

require 'digest/md5'
require 'uri'

class HttpUrlValidator < ActiveModel::EachValidator

  def self.compliant?(value)
    uri = URI.parse(value)
    uri.is_a?(URI::HTTP) && !uri.host.nil?
  rescue URI::InvalidURIError
    false
  end

  def validate_each(record, attribute, value)
    unless value.present? && self.class.compliant?(value)
      record.errors.add(attribute, "is not a valid HTTP URL")
    end
  end
end

class Member < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, #, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :payments

#  attr_accessible :given_names, :last_name, :date_of_birth, :address, :email, :phone
#  attr_accessible :card_number
#  attr_accessible :membership_paused, :membership_pause_note

  validates :given_names, :presence => true,
                          :length => {:maximum => 50}
  validates :last_name, :presence => true,
                          :length => {:maximum => 50}
#  validates :date_of_birth, :presence => true

  validates :card_number, :inclusion => {:in => 1..999999, :allow_nil => true}

  email_regex = /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+\z/

  validates :email, :format => {:with => email_regex, :allow_blank => true},
                    :uniqueness => {:case_sensitive => false, :allow_nil => true}

  validates :site_user, :uniqueness => {:allow_nil => true}

  validates :membership_pause_note, :presence => {:if => :membership_paused}

  validates :photo_url, http_url: {allow_blank: true}

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
    card_number
    site_user
    join_date
    debtor?
    last_payment_date
    last_payment_amount
    membership_paused
    membership_pause_note
  end

  def self.search(search)
    if search
      where('last_name LIKE ? OR card_number = ?', "#{Unicode::capitalize(search)}%", search.to_i)
    else
      all
    end
  end

  def self.last_card_number
    m = Member.order(card_number: :desc).first
    m.card_number
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

  def neophyte?
    self.payments.empty?
  end

  def card_number_str
    unless self.card_number.nil?
      sprintf("%06d", self.card_number)
    else
      ''
    end
  end

  def debtor?
    p = self.payments.where(:end_date => Time.now.to_date..('9999-01-01'.to_date) ).last
    p.nil?
  end

  def last_payment
    self.payments.order(:date).last
  end

  def last_payment_date
    p = self.last_payment
    if p.nil?
      nil
    else
      p.date
    end
  end

  def last_payment_amount
    p = last_payment
    if p.nil?
      nil
    else
      p.amount
    end
  end

  def paid_upto
    p = self.payments.order(:end_date).last
    if p.nil?
      nil
    else
      p.end_date
    end
  end

  def avatar_url(style)
    return photo_url unless photo_url.blank?

    hash = Digest::MD5.hexdigest(self.email.to_s.downcase)
    size = if style == :thumb
             '60x60'
           else
             style == :medium ? '200x200' : ''
           end
    "https://gravatar.com/avatar/#{hash}?d=robohash&size=#{size}"
  end

  def admin?
    false
  end

  def member?
    true
  end

  protected

  def password_required?
    false
  end

  private

  def set_nil
    self[:email] = nil if self[:email].blank?
  end

end
