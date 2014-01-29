require 'spec_helper'

describe "donations/show" do
  before(:each) do
    @donation = assign(:donation, stub_model(Donation,
      :document_number => "Document Number",
      :amount => 1,
      :donor => "Donor",
      :note => "MyText"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Document Number/)
    rendered.should match(/1/)
    rendered.should match(/Donor/)
    rendered.should match(/MyText/)
  end
end
