require 'rails_helper'

describe Hackney::PropertyByPostcode, '.build' do
  include Helpers::HackneyRepairsRequestStubs

  it 'builds a property from the API response' do
    model = described_class.build(property_by_postcode_response_body[:results].first)
    expect(model).to be_a(Hackney::PropertyByPostcode)

    expect(model.address).to eq("Homerton High Street 10 Banister House")
    expect(model.postcode).to eq("E9 6BH")
    expect(model.reference).to eq("00014663")
    expect(model.description).to eq("Dwelling")
  end
end

describe Hackney::PropertyByPostcode, '#for_postcode' do
  include Helpers::HackneyRepairsRequestStubs

  context 'when the API responds with RecordNotFound' do
    before do
      stub_hackney_property_by_postcode(status: 404)
    end

    it 'raises a RecordNotFoundError error' do
      expect {
        described_class.for_postcode('E96BH')
      }.to raise_error HackneyAPI::RepairsClient::RecordNotFoundError
    end
  end

  context 'when the API fails' do
    before do
      stub_hackney_property_by_postcode(status: 500)
    end

    it 'raises an api error' do
      expect {
        described_class.for_postcode('E96BH')
      }.to raise_error HackneyAPI::RepairsClient::ApiError
    end
  end
end
