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

  # Алгоритм: взнос действует календарный год, с 1 января по 31 декабря.
  #
  # Если заплатили в декабре — считаем как за следующий год.
  # Если оплачено в декабре, но нет действующего платежа — то действует с момента уплаты, иначе с 1 января
  #
  def fill_dates!
    paid_upto = self.member&.paid_upto
    start_of_year = (self.date + 1.month).beginning_of_year

    if (self.date.month == 12) or paid_upto.nil? or (paid_upto < self.date)
        self.start_date = self.date
    else
      if paid_upto
        self.start_date = [paid_upto + 1.day, start_of_year].min
      else
        self.start_date = start_of_year
      end
    end

    self.end_date = (self.date + 1.month).end_of_year
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

