module Api
  class PropertiesController < Api::ApiController
    def repairs_history
      @property = Hackney::Property.find(reference)
    end

    def repairs_history_5_years
      @property = Hackney::Property.find(reference)
    end

    private

    def reference
      params[:ref]
    end
  end
end
