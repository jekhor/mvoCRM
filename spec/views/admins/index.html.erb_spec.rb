require 'spec_helper'

describe "admins/index" do
  before(:each) do
    assign(:admins, [
      stub_model(Admin),
      stub_model(Admin)
    ])
  end

  it "renders a list of admins" do
    render
  end
end
