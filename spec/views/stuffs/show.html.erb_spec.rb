require 'rails_helper'

RSpec.describe "stuffs/show", type: :view do
  before(:each) do
    @stuff = assign(:stuff, Stuff.create!(
      :name => "Name"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
  end
end
