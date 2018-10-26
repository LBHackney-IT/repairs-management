module Api
  class PropertiesController < Api::ApiController
    def possibly_related_work_orders
      @property = Hackney::Property.find(reference)
    end

    def repairs_history
      @property = Hackney::Property.find(reference)
    end

    private

    def reference
      params[:ref]
    end
  end
end
