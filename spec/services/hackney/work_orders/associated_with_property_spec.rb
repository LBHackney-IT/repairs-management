require 'rails_helper'

describe Hackney::WorkOrders::AssociatedWithProperty do
  include Helpers::HackneyRepairsRequestStubs

  describe '#call' do
    let(:years_ago) { 2 }
    let(:property) { build :property }

    let(:service_instance) { described_class.new(property) }
    let(:property_hierarchy_estate)     { build(:property, reference: 'est1', description: 'Estate') }
    let(:property_hierarchy_free)       { build(:property, reference: 'fre1', description: 'Free') }
    let(:property_hierarchy_block)      { build(:property, reference: 'blo1', description: 'Block') }
    let(:property_hierarchy_random)     { build(:property, reference: 'ran1', description: 'Random') }
    let(:property_hierarchy_subblock)   { build(:property, reference: 'sub1', description: 'Sub-Block') }
    let(:property_hierarchy_facilities) { build(:property, reference: 'fac1', description: 'Facilities') }
    let(:property_hierarchy_dwelling)   { build(:property, reference: 'dwe1', description: 'Dwelling') }
    let(:property_hierarchy_nondwell)   { build(:property, reference: 'non1', description: 'Non-Dwell') }

    let(:property_hierarchy_response) do
      [
        property_hierarchy_estate,
        property_hierarchy_free,
        property_hierarchy_block,
        property_hierarchy_random,
        property_hierarchy_subblock,
        property_hierarchy_dwelling,
        property_hierarchy_nondwell
      ]
    end

    let(:property_facilities_response) do
      [
        property_hierarchy_facilities
      ]
    end

    before do
      allow(property).to receive(:hierarchy).and_return(property_hierarchy_response)
      allow(property).to receive(:facilities).and_return(property_facilities_response)
    end

    subject { service_instance.call(years_ago) }

    it 'gets a grouped list (a hash) of work orders associated with a dwelling grouped by a description' do
      properties = (property_hierarchy_response + property_facilities_response - [property_hierarchy_random])

      stub_hackney_work_orders_for_property(
        reference: properties.map(&:reference),
        body: properties.map {|p| work_order_response_payload('propertyReference' => p.reference) }
      )

      expect(subject["Estate"]).to contain_exactly(an_instance_of(Hackney::WorkOrder))
      expect(subject["Free"]).to contain_exactly(an_instance_of(Hackney::WorkOrder))
      expect(subject["Block"]).to contain_exactly(an_instance_of(Hackney::WorkOrder))
      expect(subject["Sub-Block"]).to contain_exactly(an_instance_of(Hackney::WorkOrder))
      expect(subject["Facilities"]).to contain_exactly(an_instance_of(Hackney::WorkOrder))
      expect(subject["Dwelling"]).to contain_exactly(an_instance_of(Hackney::WorkOrder))
      expect(subject["Non-Dwell"]).to contain_exactly(an_instance_of(Hackney::WorkOrder))
    end

    it 'works with a facilities hierarchy' do
      allow(property).to receive(:hierarchy).and_return(property_hierarchy_response + property_facilities_response)

      properties = (property_hierarchy_response + property_facilities_response - [property_hierarchy_random])
      stub_hackney_work_orders_for_property(
        reference: properties.map(&:reference),
        body: properties.map {|p| work_order_response_payload('propertyReference' => p.reference) }
      )

      expect(subject["Facilities"].size).to eq 1
    end

    it 'returns the hash in reverse property hierarchy "order"' do
      references = (property_hierarchy_response + property_facilities_response - [property_hierarchy_random]).map(&:reference)
      stub_hackney_work_orders_for_property(reference: references, body: [
        work_order_response_payload('propertyReference' => property_hierarchy_free.reference),
        work_order_response_payload('propertyReference' => property_hierarchy_estate.reference)
      ])

      expect(subject.keys).to eq Hackney::WorkOrders::AssociatedWithProperty::HIERARCHY_DESCRIPTIONS.reverse
    end
  end
end
