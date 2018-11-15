module Api
  class PropertiesController < Api::ApiController
    def repairs_history
      years_ago = params[:years_ago]&.to_i || 2

      @property = Hackney::Property.find(reference)

      @property_hierarchy = @property.dwelling_work_orders_hierarchy(years_ago)

      if @property_hierarchy.any?
        @trades = @property_hierarchy.values.flatten.map(&:trade).uniq.sort
        render 'repairs_history'
      else
        render 'no_repairs_history'
      end
    end

    def reference
      params[:ref]
    end
  end
end
