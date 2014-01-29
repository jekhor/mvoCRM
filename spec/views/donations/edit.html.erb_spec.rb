require 'spec_helper'

describe "donations/edit" do
  before(:each) do
    @donation = assign(:donation, stub_model(Donation,
      :document_number => "MyString",
      :amount => 1,
      :donor => "MyString",
      :note => "MyText"
    ))
  end

  it "renders the edit donation form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => donations_path(@donation), :method => "post" do
      assert_select "input#donation_document_number", :name => "donation[document_number]"
      assert_select "input#donation_amount", :name => "donation[amount]"
      assert_select "input#donation_donor", :name => "donation[donor]"
      assert_select "textarea#donation_note", :name => "donation[note]"
    end
  end
end
