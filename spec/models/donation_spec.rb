require 'spec_helper'

describe Donation do
  pending "add some examples to (or delete) #{__FILE__}"
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

