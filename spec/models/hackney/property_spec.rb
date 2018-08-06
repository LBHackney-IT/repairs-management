require 'rails_helper'

describe Hackney::Property, '.build' do
  include Helpers::HackneyRepairsRequestStubs

  it 'builds a property from the API response' do
    model = described_class.build(property_response_payload)

    expect(model).to be_a(Hackney::Property)
    expect(model.reference).to eq('00014665')
  end
end

describe Hackney::Property, '#find' do
  include Helpers::HackneyRepairsRequestStubs

  it 'finds a property' do
    stub_hackney_repairs_properties

    property = described_class.find('00014665')

    expect(property).to be_a(Hackney::Property)
    expect(property.reference).to eq('00014665')
  end

  it 'raises a RecordNotFound error when a repair request cannot be found' do
    stub_hackney_repairs_properties(status: 404)

    expect {
      described_class.find('00014665')
    }.to raise_error HackneyAPI::RepairsClient::RecordNotFoundError
  end

  it 'raises an error when the API fails to retrieve a repair request' do
    stub_hackney_repairs_properties(status: 500)

    expect {
      described_class.find('00014665')
    }.to raise_error HackneyAPI::RepairsClient::ApiError
  end
end
