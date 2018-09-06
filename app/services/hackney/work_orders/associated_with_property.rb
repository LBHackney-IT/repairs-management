module Hackney
  module WorkOrders
    class AssociatedWithProperty
      HIERARCHY_DESCRIPTIONS = %w(Estate Block Sub-Block Free Facilitices Dwelling Non-Dwell).freeze

      attr_reader :reference

      def initialize(reference)
        @reference = reference
      end

      def call
        filtered_hierarchy.each_with_object({}) do |(description, property_reference), hash|
          hash[description] = Hackney::WorkOrder.for_property(property_reference)
        end
      end

      private

      def filtered_hierarchy
        Hackney::PropertyHierarchy.for_property(reference).each_with_object({}) do |element, hash|
          hash[element.description] = element.reference if element.description.in?(HIERARCHY_DESCRIPTIONS)
        end
      end
    end
  end
end
