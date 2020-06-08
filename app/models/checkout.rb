# == Schema Information
#
# Table name: checkouts
#
#  id            :integer          not null, primary key
#  amount        :decimal(12, 2)   not null
#  customer      :string
#  message       :string
#  pay_processor :string           not null
#  raw_status    :text
#  redirect_url  :string
#  status        :string
#  token         :string
#  uid           :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  member_id     :integer
#  payment_id    :integer
#
# Indexes
#
#  index_checkouts_on_member_id   (member_id)
#  index_checkouts_on_payment_id  (payment_id)
#
# Foreign Keys
#
#  member_id   (member_id => members.id)
#  payment_id  (payment_id => payments.id)
#
class Checkout < ApplicationRecord
  belongs_to :payment, inverse_of: :checkout, optional: true
  belongs_to :member, optional: true

  serialize :customer, JSON

  validates :amount, presence: true
  validates :amount, numericality: {other_than: 0}

  def update_status!
    payproc = PayProcessor.create

    payproc.update_checkout_status!(self)
  end
end
