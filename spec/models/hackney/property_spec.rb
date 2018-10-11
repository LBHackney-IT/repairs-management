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
end

describe Hackney::Property, '.dwelling_work_orders_hierarchy' do
  let(:reference) { 'ref' }
  let(:result) { {} }
  let(:klass_instance) { described_class.new(reference: reference, address: 'address', postcode: 'postcode') }
  let(:associated_with_property_double) { instance_double(Hackney::WorkOrders::AssociatedWithProperty, call: result) }

  before do
    allow(Hackney::WorkOrders::AssociatedWithProperty).to receive(:new).with(reference).and_return(associated_with_property_double)
  end

  subject { klass_instance.dwelling_work_orders_hierarchy }

  it 'calls valid class with a property parameter' do
    expect(associated_with_property_double).to receive(:call)
    expect(subject).to eq(result)
  end
end

describe Hackney::Property, '#work_orders_plumbing_from_block_and_last_two_weeks' do
  let(:trade) { Hackney::Trades::PLUMBING }
  let(:reference) { 'reference' }
  let(:klass_instance) { described_class.new(reference: reference) }

  subject { klass_instance.work_orders_plumbing_from_block_and_last_two_weeks }

  it 'returns work orders which are not older than 2 week and have different reference than work_order.prop_ref' do
    expect(Hackney::WorkOrder).to receive(:for_property_block_and_trade).with(
      property_reference: reference,
      trade: trade,
      date_from: (Date.today - 2.weeks).strftime("%d-%m-%Y"),
      date_to: Date.today.strftime("%d-%m-%Y")
    )
    subject
  end
end
