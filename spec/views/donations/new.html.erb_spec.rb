require 'spec_helper'

describe "donations/new" do
  before(:each) do
    assign(:donation, stub_model(Donation,
      :document_number => "MyString",
      :amount => 1,
      :donor => "MyString",
      :note => "MyText"
    ).as_new_record)
  end

  it "renders new donation form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => donations_path, :method => "post" do
      assert_select "input#donation_document_number", :name => "donation[document_number]"
      assert_select "input#donation_amount", :name => "donation[amount]"
      assert_select "input#donation_donor", :name => "donation[donor]"
      assert_select "textarea#donation_note", :name => "donation[note]"
    end
  end
end
