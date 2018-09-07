require 'rails_helper'

describe Hackney::PropertyHierarchy do
  describe '.for_property' do
    let(:property) { 11111 }
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

    subject { described_class.for_property(property) }

    it 'returns an array with instances of Hackney::PropertyHierarchy built based on an API response' do
      expect(repairs_client_double).to receive(:get_property_hierarchy).with(property)
      expect(described_class).to receive(:build).once
      subject
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
        'postCode' => postcode
      }
    end

    subject { described_class.build(attributes) }

    it 'builds an instance of Hackney::PropertyHierarchy with passed attributes' do
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
