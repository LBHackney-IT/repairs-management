require 'rails_helper'

describe Hackney::WorkOrders::AssociatedWithDwelling do
  include Helpers::HackneyRepairsRequestStubs

  describe '#call' do
    let(:dwelling_reference) { 1 }

    let(:service_instance) { described_class.new(dwelling_reference) }
    let(:property_hierarchy_estate) { build(:property_hierarchy, description: 'Estate') }
    let(:property_hierarchy_free) { build(:property_hierarchy, description: 'Free') }
    let(:property_hierarchy_block) { build(:property_hierarchy, description: 'Block') }
    let(:property_hierarchy_random) { build(:property_hierarchy, description: 'Random') }
    let(:property_hierarchy_subblock) { build(:property_hierarchy, description: 'Sub-Block') }
    let(:property_hierarchy_facilities) { build(:property_hierarchy, description: 'Facilitices') }
    let(:property_hierarchy_dwelling) { build(:property_hierarchy, description: 'Dwelling') }
    let(:property_hierarchy_nondwell) { build(:property_hierarchy, description: 'Non-Dwell') }

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
      allow(Hackney::PropertyHierarchy).to receive(:for_property).with(dwelling_reference).and_return(property_hierarchy_response)

      stub_hackney_work_orders_for_property(reference: property_hierarchy_estate.reference)
      stub_hackney_work_orders_for_property(reference: property_hierarchy_free.reference)
      stub_hackney_work_orders_for_property(reference: property_hierarchy_block.reference)
      stub_hackney_work_orders_for_property(reference: property_hierarchy_subblock.reference)
      stub_hackney_work_orders_for_property(reference: property_hierarchy_facilities.reference)
      stub_hackney_work_orders_for_property(reference: property_hierarchy_dwelling.reference)
      stub_hackney_work_orders_for_property(reference: property_hierarchy_nondwell.reference)
    end

    subject { service_instance.call }

    it 'gets a grouped list (a hash) of work orders associated with a dwelling groupped by a description' do
      expect(subject["Estate"]).to contain_exactly(an_instance_of(Hackney::WorkOrder))
      expect(subject["Free"]).to contain_exactly(an_instance_of(Hackney::WorkOrder))
      expect(subject["Block"]).to contain_exactly(an_instance_of(Hackney::WorkOrder))
      expect(subject["Sub-Block"]).to contain_exactly(an_instance_of(Hackney::WorkOrder))
      expect(subject["Facilitices"]).to contain_exactly(an_instance_of(Hackney::WorkOrder))
      expect(subject["Dwelling"]).to contain_exactly(an_instance_of(Hackney::WorkOrder))
      expect(subject["Non-Dwell"]).to contain_exactly(an_instance_of(Hackney::WorkOrder))
    end
  end
end
