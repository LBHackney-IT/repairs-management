module Api
  class PropertiesController < Api::ApiController
    def repairs_history
      repairs_history_data
    end

    def repairs_history_5_years
      repairs_history_data(years_ago: 5)
    end

    def repairs_history_data(years_ago: params[:years_ago]&.to_i || 2)
      property = Hackney::Property.find(reference)

      if years_ago == 2
        @endpoint_5_years = "/api/properties/#{property.reference}/repairs_history_5_years"
      end

      @property_hierarchy = property.dwelling_work_orders_hierarchy(years_ago)

      if @property_hierarchy.any?
        @trades = property.trades_hierarchy_work_orders(years_ago)
        render 'repairs_history'
      else
        render 'no_repairs_history'
      end
    end

    private

    def reference
      params[:ref]
    end
  end
end
