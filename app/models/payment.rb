# encoding: utf-8
#
class Payment < ApplicationRecord
  belongs_to :member, optional: true
  has_one :checkout, inverse_of: :payment

#  attr_accessible :date, :amount, :start_date, :end_date, :member_id, :note, :number, :user_account, :payment_type

  validates :date, :presence => true
  validates :amount, :presence => true
  validates :start_date, presence: true, unless: [Proc.new { |p| p.payment_type == 'donation' }]
  validates :end_date, presence: true, unless: [Proc.new { |p| p.payment_type == 'donation' }]
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

  def fill_dates!
    self.start_date = self.date
    self.end_date = self.date + 1.year - 1.day

    unless self.member.nil?
      last_date = self.member.paid_upto
      if !last_date.nil? and last_date > 3.month.ago
        self.start_date = last_date + 1.day
      end
      self.end_date = self.start_date + 1.year - 1.day

      # Если на текущий момент уже оплачено, и заканчивается позже, чем через месяц,
      # то не продлеваем, а приравниваем срок к действующему
      if !last_date.nil? and last_date > Date.today + 1.month
        lp = self.member.last_payment
        self.start_date = lp.start_date
        self.end_date = lp.end_date
      end
    end
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
#  id             :integer          not null, primary key
#  amount         :decimal(10, 2)   not null
#  date           :date             not null
#  end_date       :date
#  full_name      :string
#  hg_bill        :json
#  note           :text
#  number         :string(255)
#  payment_system :string
#  payment_type   :string(255)
#  start_date     :date
#  user_account   :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  member_id      :integer
#

