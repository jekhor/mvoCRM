# encoding: utf-8
#
class Payment < ActiveRecord::Base
  belongs_to :member

  attr_accessible :date, :amount, :start_date, :end_date, :member_id, :note, :number, :user_account

  validates :date, :presence => true
  validates :amount, :presence => true
  validates :start_date, :presence => true
  validates :end_date, :presence => true
  validates :number, :uniqueness => true

  comma do
    member_id
    member_name
    date
    amount
    start_date
    end_date
    number
    user_account
  end

  private
  
  def member_name
    unless self.member.nil?
      self.member.full_name 
    else
      nil
    end
  end
end
