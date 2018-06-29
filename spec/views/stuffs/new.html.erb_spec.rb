require 'rails_helper'

RSpec.describe "stuffs/new", type: :view do
  before(:each) do
    assign(:stuff, Stuff.new(
      :name => "MyString"
    ))
  end

  it "renders new stuff form" do
    render

    assert_select "form[action=?][method=?]", stuffs_path, "post" do

      assert_select "input[name=?]", "stuff[name]"
    end
  end
end
