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
  let(:class_instance) { described_class.new(reference: reference, address: 'address', postcode: 'postcode') }
  let(:associated_with_property_double) { instance_double(Hackney::WorkOrders::AssociatedWithProperty, call: result) }

  before do
    allow(Hackney::WorkOrders::AssociatedWithProperty).to receive(:new).with(reference).and_return(associated_with_property_double)
  end

  subject { class_instance.dwelling_work_orders_hierarchy }

  it 'calls valid class with a property parameter' do
    expect(associated_with_property_double).to receive(:call)
    expect(subject).to eq(result)
  end
end

describe Hackney::Property, '#work_orders_plumbing_from_block_and_last_two_weekes' do
  let(:trade) { Hackney::Trades::PLUMBING }
  let(:reference) { 'reference' }
  let(:class_instance) { described_class.new(reference: reference) }
  let(:older_than_2_weeks) { build(:work_order, created: DateTime.current - 3.weeks) }
  let(:not_older_than_2_weeks) { build(:work_order, created: DateTime.current - 1.week) }
  let(:not_older_than_2_weeks_same_ref) { build(:work_order, created: DateTime.current - 1.week, prop_ref: reference) }
  let(:result) do
    [
      older_than_2_weeks,
      not_older_than_2_weeks
    ]
  end

  before do
    allow(Hackney::WorkOrder).to receive(:for_property_block_and_trade)
      .with(property_reference: reference, trade: trade).and_return(result)
  end

  subject { class_instance.work_orders_plumbing_from_block_and_last_two_weekes }

  it 'returns work orders which are not older than 2 week and have different reference than work_order.prop_ref' do
    expect(subject).to contain_exactly(not_older_than_2_weeks)
  end
end
