# encoding: utf-8
#
class Payment < ApplicationRecord
  belongs_to :member, optional: true

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
#  id           :integer          not null, primary key
#  amount       :decimal(10, 2)   not null
#  date         :date             not null
#  end_date     :date             not null
#  full_name    :string
#  hg_bill      :json
#  note         :text
#  number       :string(255)
#  payment_type :string(255)
#  start_date   :date             not null
#  user_account :string(255)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  member_id    :integer
#

