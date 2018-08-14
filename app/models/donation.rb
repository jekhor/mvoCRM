class Donation < ApplicationRecord
#  attr_accessible :amount, :datetime, :document_number, :donor, :note, :payment_id
  validates_uniqueness_of :payment_id
end
# == Schema Information
#
# Table name: donations
#
#  id              :integer         not null, primary key
#  document_number :string(255)
#  amount          :integer
#  donor           :string(255)
#  note            :text
#  created_at      :datetime        not null
#  updated_at      :datetime        not null
#  payment_id      :integer         default(0), not null
#  datetime        :datetime
#

