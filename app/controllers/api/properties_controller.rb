module Api
  class PropertiesController < Api::ApiController
    def possibly_related_work_orders
      @property = Hackney::Property.find(reference)
      @address_map = build_address_map(@property)
    end

    def repairs_history
      @property = Hackney::Property.find(reference)
    end

    private

    def reference
      params[:ref]
    end

    # Pre fetch addresses for all the work orders rather than delegate down to
    # the work order to avoid fetching the property multiple times
    def build_address_map(property)
      property.work_orders_plumbing_from_block_and_last_two_weeks
              .each_with_object({ property.reference => property.address }) do |work_order, map|
        map[work_order.prop_ref] ||= work_order.property.address
      end
    end
  end
end
