class Donation < ActiveRecord::Base
  attr_accessible :amount, :datetime, :document_number, :donor, :note, :payment_id
  validates_uniqueness_of :payment_id
end
