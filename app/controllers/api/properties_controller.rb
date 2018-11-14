module Api
  class PropertiesController < Api::ApiController
    def repairs_history
      @property = Hackney::Property.find(reference)
    end

    def addresses
      addresses = {}
      params['property_ids'].split(',').uniq.each do |prop_ref|
        addresses[prop_ref] = Hackney::Property.find(prop_ref).address.split('  ')
      end

      render :json => addresses
    end

    private

    def reference
      params[:ref]
    end
  end
end
