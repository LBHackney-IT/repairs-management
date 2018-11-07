module Hackney
  module WorkOrders
    class AssociatedWithProperty
      HIERARCHY_DESCRIPTIONS = %w(Estate Block Sub-Block Free Facilities Dwelling Non-Dwell).freeze

      def initialize(property)
        @property = property
      end

      def call(years_ago: 2)
        hierarchy = filtered_hierarchy
        data = hierarchy.each_with_object({}) do |(_, description), hash|
          hash[description] = []
        end

        fetch_work_orders(hierarchy.keys, years_ago).each do |wo|
          description = hierarchy[wo.prop_ref]
          data[description] << wo
        end

        data.delete_if { |_, value|  value.empty? }
      end

      private

      attr_accessor :property

      def fetch_work_orders(property_references, years_ago)
        Hackney::WorkOrder.for_property(property_references: property_references,
                                        date_from: (Date.today - years_ago.years),
                                        date_to: Date.tomorrow)
      end

      def filtered_hierarchy
        property.hierarchy.each_with_object({}) do |element, hash|
          hash[element.reference] = element.description if element.description.in?(HIERARCHY_DESCRIPTIONS)
        end
      end
    end
  end
end
