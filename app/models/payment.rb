class Payment < ActiveRecord::Base
  belongs_to :member

  attr_accessible :date, :amount, :start_date, :end_date, :member_id, :note

  validates :date, :presence => true
  validates :amount, :presence => true
  validates :start_date, :presence => true
  validates :end_date, :presence => true
end