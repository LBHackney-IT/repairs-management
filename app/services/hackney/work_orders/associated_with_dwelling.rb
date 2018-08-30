module Hackney
  module WorkOrders
    class AssociatedWithDwelling
      HIERARCHY_DESCRIPTIONS = %w(Estate Block Sub-Block Free Facilitices Dwelling Non-Dwell).freeze

      attr_reader :dwelling_reference

      def initialize(dwelling_reference)
        @dwelling_reference = dwelling_reference
      end

      def call
        filtered_hierarchy.each_with_object({}) do |(description, property_reference), hash|
          hash[description] = api_work_orders_by_property(property_reference).map do |work_order_attributes|
            Hackney::WorkOrder.build(work_order_attributes)
          end
        end
      end

      private

      def dwelling_hierarchy
        Hackney::PropertyHierarchy.for_property(dwelling_reference)
      end

      def filtered_hierarchy
        dwelling_hierarchy.each_with_object({}) do |element, hash|
          hash[element.description] = element.reference if element.description.in?(HIERARCHY_DESCRIPTIONS)
        end
      end

      def api_work_orders_by_property(property_reference)
        HackneyAPI::RepairsClient.new.get_work_orders_by_property(property_reference)
      end
    end
  end
end
