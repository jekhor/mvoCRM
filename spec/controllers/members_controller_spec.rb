require 'spec_helper'

describe MembersController do

  render_views

  before :each do
    @base_title = "mvoCRM | "
    @member = Factory(:member)
  end

  describe "GET 'index'" do
    it "should be successful" do
      get 'index'
      response.should be_success
    end

    it "should have the right title" do
      get 'index'
      response.should have_selector("title",
                                    :content => "#{@base_title}Members")
    end

  end

  describe "GET 'new'" do
    it "should be successful" do
      get 'new'
      response.should be_success
    end

    it "should have the right title" do
      get 'new'
      response.should have_selector("title",
                                    :content => "#{@base_titile}New Member")
    end
  end

  describe "GET 'show'" do
    it "should be successful" do
      get 'show', :id => @member
      response.should be_success
    end

    it "should find the right member" do
      get 'show', :id => @member
      assigns(:member).should == @member
    end

    it "should have the right title" do
      get 'show', :id => @member
      response.should have_selector("title", :content => "#{@member.last_name} #{@member.given_names}")
    end

    it "should include user name in header" do
      get 'show', :id => @member
      response.should have_selector("h2", :content => "#{@member.last_name} #{@member.given_names}")
    end

  end


end
