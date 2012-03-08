require 'spec_helper'

describe "LayoutLinks" do

  it "should have a Home page at '/'" do
    get '/'
    response.should have_selector('title', :content => "Home")
  end

#  it "should have an Sign In page at '/signin'" do
#    get '/signin'
#    response.should have_selector('title', :content => "About")
#  end

  it "should have a Help page at '/help'" do
    get '/help'
    response.should have_selector('title', :content => "Help")
  end

  it "should have a Members page at /members" do
    get '/members'
    response.should have_selector('title', :content => "Members")
  end

end
