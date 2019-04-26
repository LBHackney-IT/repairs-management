require 'rails_helper'

describe Hackney::Property do
  include Helpers::HackneyRepairsRequestStubs

  describe '.build for the property api' do

    it 'builds a property from the API response' do
      model = described_class.build(property_response_payload)

      expect(model).to be_a(Hackney::Property)
      expect(model.reference).to eq('00014665')
    end
  end

  describe '.build for the hierarchy json' do
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


  describe '.build for the postcode search' do

    it 'builds a property from the API response' do
      model = described_class.build(property_by_postcode_response_body[:results].first)
      expect(model).to be_a(Hackney::Property)

      expect(model.address).to eq("Homerton High Street 10 Banister House")
      expect(model.postcode).to eq("E9 6BH")
      expect(model.reference).to eq("00014663")
      expect(model.description).to eq("Dwelling")
    end
  end

  describe '.build for the address search' do

    it 'builds a property from the API response' do
      model = described_class.build(property_by_address_response_body[:results].first)
      expect(model).to be_a(Hackney::Property)

      expect(model.address).to eq("1 Acacia House  Lordship Road")
      expect(model.postcode).to eq("N16 0PX")
      expect(model.reference).to eq("00000017")
      expect(model.description).to eq("Dwelling")
    end
  end

  describe '.find' do

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

  describe '.find_all' do

    it 'fetches multiple properties' do
      stub_hackney_repairs_properties_by_references(references: ["00000001", "00000002"], body: [
        property_response_payload(property_reference: "00000001", postcode: "ABC 123"),
        property_response_payload(property_reference: "00000002", postcode: "CBA 321"),
      ])

      properties = described_class.find_all(["00000001", "00000002"])

      expect(properties.size).to eq 2
      expect(properties.first.reference).to eq '00000001'
      expect(properties.first.postcode).to eq 'ABC 123'
      expect(properties.last.reference).to eq '00000002'
      expect(properties.last.postcode).to eq 'CBA 321'
    end

    it 'returns [] if the references are not found' do
      stub_hackney_repairs_properties_by_references(status: 404, references: ["00000001"], body: {
        "developerMessage": "Exception of type 'HackneyRepairs.Actions.MissingWorkOrderException' was thrown.",
        "userMessage": "Could not find one or more of the given work orders"
      })

      expect(described_class.find_all(["00000001"])).to eq []
    end
  end

  describe '.for_postcode' do

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

  describe '.for_address' do

    context 'when the API responds with RecordNotFound' do
      before do
        stub_hackney_property_by_address(status: 404, limit: 201)
      end

      it 'raises a RecordNotFoundError error' do
        expect {
          described_class.for_address('Acacia', limit: 201)
        }.to raise_error HackneyAPI::RepairsClient::RecordNotFoundError
      end
    end

    context 'when the API fails' do
      before do
        stub_hackney_property_by_address(status: 500, limit: 201)
      end

      it 'raises an api error' do
        expect {
          described_class.for_address('Acacia', limit: 201)
        }.to raise_error HackneyAPI::RepairsClient::ApiError
      end
    end
  end

  describe '#possibly_related' do
    let(:trade) { Hackney::Trades::PLUMBING }
    let(:reference) { 'reference' }
    let(:class_instance) { described_class.new(reference: reference) }

    let(:two_weeks_ago) { Date.today - 2.weeks }
    let(:today) { Date.today }

    subject { class_instance.possibly_related(from: two_weeks_ago, to: today) }

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

  describe '#facilities' do
    let(:hierarchy_response) do
      [{
        'propertyReference' => '001',
        'levelCode' => '2',
        'description' => 'Estate',
        'majorReference' => '000',
        'address' => '5',
        'postCode' => 'W1A 1AA'
      }]
    end

    let(:by_postcode_response) do
      {
        'results' => [{
                        'propertyReference' => '002',
                        'levelCode' => '6',
                        'description' => 'Facilities',
                        'majorReference' => '001',
                        'address' => '5',
                        'postCode' => 'W1A 1AA'
                      }]
      }
    end

    let(:repairs_client_double) { instance_double(HackneyAPI::RepairsClient) }

    before do
      allow(HackneyAPI::RepairsClient).to receive(:new).and_return(repairs_client_double)
      allow(repairs_client_double).to receive(:get_property_hierarchy).with('003') { hierarchy_response }
      allow(repairs_client_double)
        .to receive(:get_facilities_by_property_reference)
        .with('003') { by_postcode_response }
    end

    subject { build :property, reference: '003', postcode: 'W1A 1AA' }

    it 'finds facilities associated with the same hierarchy' do
      expect(subject.facilities.map(&:reference)).to eq ['002']
    end
  end

  describe '#is_estate?' do

    it 'returns false if a property is not an estate' do
      property = Hackney::Property.build(property_response_payload)
      expect(property.is_estate?).to eq(false)
    end

    it 'returns true if a property is an estate' do
      property = Hackney::Property.build(property_response_payload(level_code: 2))
      expect(property.is_estate?).to eq(true)
    end
  end

  describe '#dwelling_work_orders_hierarchy' do
    let(:reference) { 'ref' }
    let(:years_ago) { 2 }
    let(:result) { {} }
    let(:class_instance) { described_class.new(reference: reference, address: 'address', postcode: 'postcode') }
    let(:associated_with_property_double) { instance_double(Hackney::WorkOrders::AssociatedWithProperty, call: result) }

    before do
      allow(Hackney::WorkOrders::AssociatedWithProperty).to receive(:new).with(class_instance).and_return(associated_with_property_double)
    end

    subject { class_instance.dwelling_work_orders_hierarchy(years_ago) }

    it 'calls valid class with a property parameter' do
      expect(associated_with_property_double).to receive(:call)
      expect(subject).to eq(result)
    end
  end

  describe '#can_raise_a_repair?' do
    it 'is only true for some tenure codes' do
      expect(Hackney::Property.new(tenure_code: '').can_raise_a_repair?).to be_truthy
      expect(Hackney::Property.new(tenure_code: nil).can_raise_a_repair?).to be_truthy
      expect(Hackney::Property.new(tenure_code: 'ASY').can_raise_a_repair?).to be_truthy
      expect(Hackney::Property.new(tenure_code: 'COM').can_raise_a_repair?).to be_truthy
      expect(Hackney::Property.new(tenure_code: 'DEC').can_raise_a_repair?).to be_truthy
      expect(Hackney::Property.new(tenure_code: 'FRE').can_raise_a_repair?).to be_falsey
      expect(Hackney::Property.new(tenure_code: 'FRS').can_raise_a_repair?).to be_truthy
      expect(Hackney::Property.new(tenure_code: 'HPH').can_raise_a_repair?).to be_falsey
      expect(Hackney::Property.new(tenure_code: 'INT').can_raise_a_repair?).to be_truthy
      expect(Hackney::Property.new(tenure_code: 'LEA').can_raise_a_repair?).to be_truthy
      expect(Hackney::Property.new(tenure_code: 'LHS').can_raise_a_repair?).to be_falsey
      expect(Hackney::Property.new(tenure_code: 'LTA').can_raise_a_repair?).to be_falsey
      expect(Hackney::Property.new(tenure_code: 'MPA').can_raise_a_repair?).to be_truthy
      expect(Hackney::Property.new(tenure_code: 'NON').can_raise_a_repair?).to be_truthy
      expect(Hackney::Property.new(tenure_code: 'PVG').can_raise_a_repair?).to be_truthy
      expect(Hackney::Property.new(tenure_code: 'RSL').can_raise_a_repair?).to be_falsey
      expect(Hackney::Property.new(tenure_code: 'RTM').can_raise_a_repair?).to be_falsey
      expect(Hackney::Property.new(tenure_code: 'SEC').can_raise_a_repair?).to be_truthy
      expect(Hackney::Property.new(tenure_code: 'SHO').can_raise_a_repair?).to be_falsey
      expect(Hackney::Property.new(tenure_code: 'SLL').can_raise_a_repair?).to be_falsey
      expect(Hackney::Property.new(tenure_code: 'SMW').can_raise_a_repair?).to be_falsey
      expect(Hackney::Property.new(tenure_code: 'SPS').can_raise_a_repair?).to be_falsey
      expect(Hackney::Property.new(tenure_code: 'SPT').can_raise_a_repair?).to be_falsey
      expect(Hackney::Property.new(tenure_code: 'SSE').can_raise_a_repair?).to be_falsey
      expect(Hackney::Property.new(tenure_code: 'TAF').can_raise_a_repair?).to be_truthy
      expect(Hackney::Property.new(tenure_code: 'TBB').can_raise_a_repair?).to be_falsey
      expect(Hackney::Property.new(tenure_code: 'TGA').can_raise_a_repair?).to be_truthy
      expect(Hackney::Property.new(tenure_code: 'THA').can_raise_a_repair?).to be_falsey
      expect(Hackney::Property.new(tenure_code: 'THL').can_raise_a_repair?).to be_falsey
      expect(Hackney::Property.new(tenure_code: 'THO').can_raise_a_repair?).to be_falsey
      expect(Hackney::Property.new(tenure_code: 'TLA').can_raise_a_repair?).to be_falsey
      expect(Hackney::Property.new(tenure_code: 'TPL').can_raise_a_repair?).to be_falsey
      expect(Hackney::Property.new(tenure_code: 'TRA').can_raise_a_repair?).to be_truthy
    end
  end
end

