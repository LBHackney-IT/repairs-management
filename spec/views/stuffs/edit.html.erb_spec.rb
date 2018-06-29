require 'rails_helper'

RSpec.describe "stuffs/edit", type: :view do
  before(:each) do
    @stuff = assign(:stuff, Stuff.create!(
      :name => "MyString"
    ))
  end

  it "renders the edit stuff form" do
    render

    assert_select "form[action=?][method=?]", stuff_path(@stuff), "post" do

      assert_select "input[name=?]", "stuff[name]"
    end
  end
end
