# encoding: utf-8
#
# == Schema Information
#
# Table name: members
#
#  id                     :integer          not null, primary key
#  address                :string(255)
#  card_number            :integer
#  confirmation_sent_at   :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :string
#  date_of_birth          :date
#  email                  :string(255)
#  encrypted_password     :string           default(""), not null
#  given_names            :string(255)
#  join_date              :date
#  last_name              :string(255)
#  last_reminded          :date
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :string
#  membership_pause_note  :text
#  membership_paused      :boolean
#  phone                  :string(255)
#  photo_url              :string
#  postal_address         :string(255)
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  sign_in_count          :integer          default(0), not null
#  site_user              :string(255)
#  subscribe_to_mails     :boolean          default(FALSE)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_members_on_confirmation_token    (confirmation_token) UNIQUE
#  index_members_on_email                 (email) UNIQUE
#  index_members_on_reset_password_token  (reset_password_token) UNIQUE
#  index_members_on_site_user             (site_user) UNIQUE
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

  it "should not require a date of birth" do
    no_dateofbirth_member = Member.new(@attr.merge(:date_of_birth => ''))
    no_dateofbirth_member.should be_valid
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

  it "should convert empty email to nil" do
    m = Member.new(@attr.merge(:email => ''))
    m.save
    m.email.should be_nil
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

  it "should not reject duplicate nil e-mail addresses" do
    attr = @attr.merge(:email => nil)
    Member.create!(attr)
    m = Member.new(attr)
    m.should be_valid
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

  it "should accept official address" do
    addr = "220112, г. Минск, Игуменский тракт, 40-24"
    m = Member.new(@attr.merge(:address => addr))
    m.should be_valid
  end

  it "should accept real postal address" do
    addr = "220112, г. Минск, Игуменский тракт, 40-24"
    m = Member.new(@attr.merge(:postal_address => addr))
    m.should be_valid
  end

  it "should accept application date if application exists" do
    m = Member.new(@attr.merge(:application_exists => true, :application_date => '2012-01-01'))
    m.should be_valid
  end

  it "should not accept empty application date if application exists" do
    m = Member.new(@attr.merge(:application_exists => true, :application_date => nil))
    m.should_not be_valid
  end

  it "should accept site_user" do
    m = Member.new(@attr.merge(:site_user => 'jekhor'))
    m.should be_valid
  end

  it "should normalize site_user as site_user_normalized" do
    m = Member.new(@attr.merge(:site_user => 'jekhor.jekhor_jekhor'))
    m.site_user_normalized.should == 'jekhorjekhorjekhor'
  end

end
