require 'spec_helper'

describe "admins/edit" do
  before(:each) do
    @admin = assign(:admin, stub_model(Admin))
  end

  it "renders the edit admin form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => admins_path(@admin), :method => "post" do
    end
  end
end
