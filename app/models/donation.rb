class Donation < ActiveRecord::Base
  attr_accessible :amount, :date, :document_number, :donor, :note
end
