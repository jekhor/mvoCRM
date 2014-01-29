require 'spec_helper'

describe "donations/index" do
  before(:each) do
    assign(:donations, [
      stub_model(Donation,
        :document_number => "Document Number",
        :amount => 1,
        :donor => "Donor",
        :note => "MyText"
      ),
      stub_model(Donation,
        :document_number => "Document Number",
        :amount => 1,
        :donor => "Donor",
        :note => "MyText"
      )
    ])
  end

  it "renders a list of donations" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Document Number".to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => "Donor".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
  end
end
