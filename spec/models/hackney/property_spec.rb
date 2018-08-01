require 'rails_helper'

describe Hackney::Property, '.build' do
  include Helpers::HackneyRepairsRequestStubs

  it 'builds a property from the API response' do
    model = described_class.build(property_response_payload)

    expect(model).to be_a(Hackney::Property)
    expect(model.reference).to eq('00014665')
  end
end
