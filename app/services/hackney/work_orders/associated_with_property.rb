module Hackney
  module WorkOrders
    class AssociatedWithProperty
      HIERARCHY_DESCRIPTIONS = %w(Estate Block Sub-Block Free Facilities Dwelling Non-Dwell).freeze

      def initialize(property)
        @property = property
      end

      def call(years_ago)
        hierarchy = filtered_hierarchy
        data = hierarchy.each_with_object({}) do |(_, description), hash|
          hash[description] = []
        end

        fetch_work_orders(hierarchy.keys, years_ago).each do |wo|
          description = hierarchy[wo.prop_ref]
          data[description] << wo
        end

        data

      end

      private

      attr_accessor :property

      def fetch_work_orders(property_references, years_ago)
        Hackney::WorkOrder.for_property(property_references: property_references,
                                        date_from: (Date.today - years_ago.years),
                                        date_to: Date.tomorrow)
      end

      def filtered_hierarchy
        hierarchy = property.hierarchy + property.facilities

        hierarchy.select! {|property| property.description.in?(HIERARCHY_DESCRIPTIONS) }

        hierarchy.sort! { |p1, p2| ord(p2) <=> ord(p1) }

        hierarchy.each_with_object({}) do |property, hash|
          hash[property.reference] = property.description
        end
      end

      def ord(property)
        HIERARCHY_DESCRIPTIONS.index(property.description)
      end
    end
  end
end
