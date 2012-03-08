# encoding: utf-8
#
# == Schema Information
#
# Table name: members
#
#  id                 :integer         not null, primary key
#  given_names        :string(255)
#  last_name          :string(255)
#  date_of_birth      :date
#  address            :string(255)
#  email              :string(255)
#  phone              :string(255)
#  created_at         :datetime        not null
#  updated_at         :datetime        not null
#  application_exists :boolean         default(FALSE)
#  join_date          :date
#  join_protocol      :string(255)
#  card_number        :integer
#  joined             :boolean
#

require 'spec_helper'

describe Member do

  before(:each) do
    @attr = {:given_names => "Иван Петрович", :last_name => 'Сидоров', :date_of_birth => "1984-07-21", :email => "test@example.com"}
  end

  it "should create a new instance given valid attributes" do
    Member.create!(@attr)
  end

  it "should requre given_names" do
    no_given_names_member = Member.new(@attr.merge(:given_names => ''))
    no_given_names_member.should_not be_valid
  end

  it "should reject too long given names" do
    long_gn = "a" * 51
    m = Member.new(@attr.merge(:given_names => long_gn))
    m.should_not be_valid
  end

  it "should require a last name" do
    no_lastname_member = Member.new(@attr.merge(:last_name => ''))
    no_lastname_member.should_not be_valid
  end

  it "should reject too long last name" do
    long_ln = "a" * 51
    m = Member.new(@attr.merge(:last_name => long_ln))
    m.should_not be_valid
  end

  it "should require a date of birth" do
    no_dateofbirth_member = Member.new(@attr.merge(:date_of_birth => ''))
    no_dateofbirth_member.should_not be_valid
  end

  describe "joined member" do
    attr_joined = {:joined => true, :join_date => '2009-02-05', :join_protocol => '5'}

    it "should be valid joined member" do
      attr = @attr.merge attr_joined
      m = Member.create!(attr)
      m.should be_valid
    end

    it "should require join_date" do
      attr = @attr.merge attr_joined
      m = Member.new(attr.merge(:join_date => ''))
      m.should_not be_valid
    end

    it "should require join_protocol" do
      attr = @attr.merge attr_joined
      m = Member.new(attr.merge(:join_protocol => ''))
      m.should_not be_valid
    end
  end

  it "should not allow empty but not nil email" do
    m = Member.new(@attr.merge(:email => ''))
    m.should_not be_valid
  end

  it "should accept valid e-mail addresses" do
    valid_addresses = ['niceandsimple@example.com', 'simplewith+symbol@example.com', 'less.common@example.com',
      'a.little.more.unusual@dept.example.com'
    ]

    valid_addresses.each do |addr|
      m = Member.new(@attr.merge(:email => addr))
      m.should be_valid
    end
  end

  it "should not accept invalid e-mail addresses" do

    invalid_addresses = ['Abc.example.com', 'A@b@c@example.com',
      'a"b(c)d,e:f;g<h>i[j\k]l@example.com', 'just"not"right@example.com', 'this is"not\allowed@example.com',
      'this\ still\"not\\allowed@example.com'
    ]

    invalid_addresses.each do |addr|
      m = Member.new(@attr.merge(:email => addr))
      m.should_not be_valid
    end
  end

  it "should reject duplicate e-mail addresses" do
    attr = @attr.merge(:email => 'test@example.com')
    Member.create!(attr)
    m = Member.new(attr)
    m.should_not be_valid
  end

  it "should reject duplicate e-mail addresses with any case" do
    attr = @attr.merge(:email => 'test@example.com')
    attr_up = @attr.merge(:email => 'TEST@EXAMPLE.COM')
    Member.create!(attr)
    m = Member.new(attr_up)
    m.should_not be_valid
  end

  describe 'card_number' do
    it "should accept nil value" do
      m = Member.new(@attr.merge(:card_number => nil))
      m.should be_valid
    end

    it "should not accept non-integers" do
      m = Member.new(@attr.merge(:card_number => 'asdfghjkl'))
      m.should_not be_valid
    end

    it "should not accept 0" do
      m = Member.new(@attr.merge(:card_number => 0))
      m.should_not be_valid
    end

    it "should not accept negative values" do
      m = Member.new(@attr.merge(:card_number => -1))
      m.should_not be_valid
    end

    it "should accept values upto 999999" do
      m = Member.new(@attr.merge(:card_number => 999999))
      m.should be_valid
    end

    it "should not accept values after 999999" do
      m = Member.new(@attr.merge(:card_number => 1000000))
      m.should_not be_valid
    end
  end

end
