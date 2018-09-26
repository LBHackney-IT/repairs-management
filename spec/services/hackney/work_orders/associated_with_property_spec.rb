require 'rails_helper'

describe Hackney::WorkOrders::AssociatedWithProperty do
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

    let(:property_reference_response_body) do
      [
        {
          "sorCode" => "20060060",
          "trade" => "Plumbing",
          "workOrderReference" => "00545095",
          "repairRequestReference" => "02054981",
          "problemDescription" => "rem - leak affecting 2 props below.",
          "created" => "2010-12-20T09:53:27",
          "estimatedCost" => 115.02,
          "actualCost" => 0,
          "completedOn" => "1900-01-01T00:00:00",
          "dateDue" => "2011-01-18T09:53:00",
          "workOrderStatus" => "300",
          "dloStatus" => "3",
          "servitorReference" => "00746221",
          "propertyReference" => "00014665"
        }
      ]
    end

    before do
      allow(Hackney::PropertyHierarchy).to receive(:for_property).with(dwelling_reference).and_return(property_hierarchy_response)
    end

    subject { service_instance.call }

    it 'gets a grouped list (a hash) of work orders associated with a dwelling groupped by a description' do
      property_hierarchy_response.each do |property_hierarchy|
        stub_hackney_work_orders_for_property(reference: property_hierarchy.reference, body: property_reference_response_body)
      end

      expect(subject["Estate"]).to contain_exactly(an_instance_of(Hackney::WorkOrder))
      expect(subject["Free"]).to contain_exactly(an_instance_of(Hackney::WorkOrder))
      expect(subject["Block"]).to contain_exactly(an_instance_of(Hackney::WorkOrder))
      expect(subject["Sub-Block"]).to contain_exactly(an_instance_of(Hackney::WorkOrder))
      expect(subject["Facilitices"]).to contain_exactly(an_instance_of(Hackney::WorkOrder))
      expect(subject["Dwelling"]).to contain_exactly(an_instance_of(Hackney::WorkOrder))
      expect(subject["Non-Dwell"]).to contain_exactly(an_instance_of(Hackney::WorkOrder))
    end

    it 'returns and empty hash when there are no work orders for any property in the heirarchy' do
      property_hierarchy_response.each do |property_hierarchy|
        stub_hackney_work_orders_for_property(reference: property_hierarchy.reference, body: [])
      end

      expect(subject).to be_empty
    end
  end
end
