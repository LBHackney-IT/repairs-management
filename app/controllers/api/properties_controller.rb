module Api
  class PropertiesController < Api::ApiController
    def repairs_history
      repairs_history_data
    end

    def repairs_history_5_years
      repairs_history_data(years_ago: 5)
    end

    def repairs_history_data(years_ago: 2)
      property = Hackney::Property.find(reference)
      property_reference = property.reference

      @property_hierarchy = property.dwelling_work_orders_hierarchy(years_ago)
      @trades = property.trades_hierarchy_work_orders(years_ago)
      @endpoint = "/api/properties/#{property_reference}/repairs_history_5_years"

      if @property_hierarchy.any?
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
