require 'rails_helper'

RSpec.describe "stuffs/index", type: :view do
  before(:each) do
    assign(:stuffs, [
      Stuff.create!(
        :name => "Name"
      ),
      Stuff.create!(
        :name => "Name"
      )
    ])
  end

  it "renders a list of stuffs" do
    render
    assert_select "tr>td", :text => "Name".to_s, :count => 2
  end
end
