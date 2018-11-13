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
    allow(Hackney::WorkOrders::AssociatedWithProperty).to receive(:new).with(klass_instance).and_return(associated_with_property_double)
  end

  subject { klass_instance.dwelling_work_orders_hierarchy }

  it 'calls valid class with a property parameter' do
    expect(associated_with_property_double).to receive(:call)
    expect(subject).to eq(result)
  end
end

describe Hackney::Property, '#possibly_related' do
  let(:trade) { Hackney::Trades::PLUMBING }
  let(:reference) { 'reference' }
  let(:klass_instance) { described_class.new(reference: reference) }

  let(:two_weeks_ago) { Date.today - 2.weeks }
  let(:today) { Date.today }

  subject { klass_instance.possibly_related(from: two_weeks_ago, to: today) }

  it 'returns work orders which are not older than 2 week and have different reference than work_order.prop_ref' do
    expect(Hackney::WorkOrder).to receive(:for_property_block_and_trade).with(
      property_reference: reference,
      trade: trade,
      date_from: two_weeks_ago.strftime("%d-%m-%Y"),
      date_to: today.strftime("%d-%m-%Y")
    )
    subject
  end
end

describe Hackney::Property do
  describe '#hierarchy' do
    let(:hierarchy_object) do
      {
        'propertyReference' => '1',
        'levelCode' => '2',
        'description' => '3',
        'majorReference' => '4',
        'address' => '5',
        'postCode' => '6'
      }
    end
    let(:api_response) { [hierarchy_object] }
    let(:repairs_client_double) { instance_double(HackneyAPI::RepairsClient, get_property_hierarchy: api_response) }

    before do
      allow(HackneyAPI::RepairsClient).to receive(:new).and_return(repairs_client_double)
    end

    subject { build :property, reference: 11111 }

    it 'returns an array with instances of Hackney::Property built based on an API response' do
      expect(repairs_client_double).to receive(:get_property_hierarchy).with(subject.reference)
      expect(described_class).to receive(:build).once

      subject.hierarchy
    end
  end

  describe '.build' do
    let(:postcode) { 'postcode' }
    let(:reference) { 'reference' }
    let(:level_code) { 'level_code' }
    let(:description) { 'description' }
    let(:major_reference) { 'major_reference' }
    let(:address) { 'address' }
    let(:attributes) do
      {
        'propertyReference' => reference,
        'levelCode' => level_code,
        'description' => description,
        'majorReference' => major_reference,
        'address' => address,
        'postcode' => postcode
      }
    end

    subject { described_class.build(attributes) }

    it 'builds an instance of Hackney::Property with passed attributes' do
      expect(subject).to be_an_instance_of(described_class)
      expect(subject.postcode).to eq(postcode)
      expect(subject.reference).to eq(reference)
      expect(subject.description).to eq(description)
      expect(subject.level_code).to eq(level_code)
      expect(subject.major_reference).to eq(major_reference)
      expect(subject.address).to eq(address)
    end
  end
end

describe Hackney::Property, '.build' do
  include Helpers::HackneyRepairsRequestStubs

  it 'builds a property from the API response' do
    model = described_class.build(property_by_postcode_response_body[:results].first)
    expect(model).to be_a(Hackney::Property)

    expect(model.address).to eq("Homerton High Street 10 Banister House")
    expect(model.postcode).to eq("E9 6BH")
    expect(model.reference).to eq("00014663")
    expect(model.description).to eq("Dwelling")
  end
end

describe Hackney::Property, '#for_postcode' do
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
