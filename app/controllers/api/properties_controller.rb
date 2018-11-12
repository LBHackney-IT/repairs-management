module Api
  class PropertiesController < Api::ApiController
    def possibly_related_work_orders
      property = Hackney::Property.find(reference)

      if property.is_estate?
        render 'possibly_related_for_estate'
      else
        work_orders = property.possibly_related(from: (Date.today - 2.weeks), to: Date.today)

        if work_orders.empty?
          render 'possibly_related_empty_result'
        else
          @possibly_related_to_address = {}

          work_orders.each do |wo|
            @possibly_related_to_address[wo] = find_and_cache_address(wo)
          end
          # render possibly_related_work_orders
        end
      end
    end

    def repairs_history
      @property = Hackney::Property.find(reference)
    end

    private

    def find_and_cache_address(work_order)
      @_addresses ||= {}
      @_addresses[work_order.prop_ref] || Hackney::Property.find(work_order.prop_ref).address
    end

    def reference
      params[:ref]
    end
  end
end
