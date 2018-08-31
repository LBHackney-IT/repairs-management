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

  context 'when the API responds with a record' do
    before do
      stub_hackney_repairs_properties
    end

    it 'finds a property' do
      property = described_class.find('00014665')

      expect(property).to be_a(Hackney::Property)
      expect(property.reference).to eq('00014665')
    end
  end

  context 'when the API responds with RecordNotFound' do
    before do
      stub_hackney_repairs_properties(status: 404)
    end

    it 'raises a RecordNotFoundError error' do
      expect {
        described_class.find('00014665')
      }.to raise_error HackneyAPI::RepairsClient::RecordNotFoundError
    end
  end

  context 'when the API fails' do
    before do
      stub_hackney_repairs_properties(status: 500)
    end

    it 'raises an api error' do
      expect {
        described_class.find('00014665')
      }.to raise_error HackneyAPI::RepairsClient::ApiError
    end
  end

  describe Hackney::Property, '.dwelling_work_orders_hierarchy' do
    let(:reference) { 'ref' }
    let(:result) { {} }
    let(:class_instance) { described_class.new(reference: reference, address: 'address', postcode: 'postcode') }
    let(:associated_with_property_double) { instance_double(Hackney::WorkOrders::AssociatedWithProperty, call: result) }

    before do
      allow(Hackney::WorkOrders::AssociatedWithProperty).to receive(:new).with(property).and_return(associated_with_property_double)
    end

    subject { class_instance.call }

    it 'calls valid class with a property parameter' do
      expect(associated_with_property_double).to receive(:call)
      expect(subject).to eq(result)
    end
  end
end
