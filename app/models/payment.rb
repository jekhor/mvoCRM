# encoding: utf-8
#
class Payment < ApplicationRecord
  belongs_to :member

#  attr_accessible :date, :amount, :start_date, :end_date, :member_id, :note, :number, :user_account, :payment_type

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
# == Schema Information
#
# Table name: payments
#
#  id           :integer         not null, primary key
#  member_id    :integer
#  date         :date            not null
#  amount       :decimal(10, 2)  not null
#  start_date   :date            not null
#  end_date     :date            not null
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#  note         :text
#  number       :string(255)
#  user_account :string(255)
#  payment_type :string(255)
#

