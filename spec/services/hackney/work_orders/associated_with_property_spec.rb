require 'rails_helper'

describe Hackney::WorkOrders::AssociatedWithProperty do
  include Helpers::HackneyRepairsRequestStubs

  describe '#call' do
    let(:years_ago) { 2 }
    let(:property) { build :property }

    let(:service_instance) { described_class.new(property) }
    let(:property_hierarchy_estate) { build(:property, description: 'Estate') }
    let(:property_hierarchy_free) { build(:property, description: 'Free') }
    let(:property_hierarchy_block) { build(:property, description: 'Block') }
    let(:property_hierarchy_random) { build(:property, description: 'Random') }
    let(:property_hierarchy_subblock) { build(:property, description: 'Sub-Block') }
    let(:property_hierarchy_facilities) { build(:property, description: 'Facilities') }
    let(:property_hierarchy_dwelling) { build(:property, description: 'Dwelling') }
    let(:property_hierarchy_nondwell) { build(:property, description: 'Non-Dwell') }

    let(:property_hierarchy_response) do
      [
        property_hierarchy_estate,
        property_hierarchy_free,
        property_hierarchy_block,
        property_hierarchy_random,
        property_hierarchy_subblock,
        property_hierarchy_facilities,
        property_hierarchy_dwelling,
        property_hierarchy_nondwell
      ]
    end

    before do
      allow(property).to receive(:hierarchy).and_return(property_hierarchy_response)
    end

    subject { service_instance.call(years_ago) }

    it 'gets a grouped list (a hash) of work orders associated with a dwelling grouped by a description' do
      references = (property_hierarchy_response - [property_hierarchy_random]).map(&:reference)
      stub_hackney_work_orders_for_property(reference: references, body: [
        work_order_response_payload('propertyReference' => property_hierarchy_estate.reference),
        work_order_response_payload('propertyReference' => property_hierarchy_free.reference),
        work_order_response_payload('propertyReference' => property_hierarchy_block.reference),
        work_order_response_payload('propertyReference' => property_hierarchy_subblock.reference),
        work_order_response_payload('propertyReference' => property_hierarchy_facilities.reference),
        work_order_response_payload('propertyReference' => property_hierarchy_dwelling.reference),
        work_order_response_payload('propertyReference' => property_hierarchy_nondwell.reference)
      ])

      expect(subject["Estate"]).to contain_exactly(an_instance_of(Hackney::WorkOrder))
      expect(subject["Free"]).to contain_exactly(an_instance_of(Hackney::WorkOrder))
      expect(subject["Block"]).to contain_exactly(an_instance_of(Hackney::WorkOrder))
      expect(subject["Sub-Block"]).to contain_exactly(an_instance_of(Hackney::WorkOrder))
      expect(subject["Facilities"]).to contain_exactly(an_instance_of(Hackney::WorkOrder))
      expect(subject["Dwelling"]).to contain_exactly(an_instance_of(Hackney::WorkOrder))
      expect(subject["Non-Dwell"]).to contain_exactly(an_instance_of(Hackney::WorkOrder))
    end

    it 'returns the hash in the same order as the property hierarchy' do
      references = (property_hierarchy_response - [property_hierarchy_random]).map(&:reference)
      stub_hackney_work_orders_for_property(reference: references, body: [
        work_order_response_payload('propertyReference' => property_hierarchy_free.reference),
        work_order_response_payload('propertyReference' => property_hierarchy_estate.reference)
      ])

      expect(subject.keys).to eq %w(Estate Free Block Sub-Block Facilities Dwelling Non-Dwell)
    end
  end
end
