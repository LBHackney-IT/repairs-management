class PropertiesController < ApplicationController
  rescue_from HackneyAPI::RepairsClient::RecordNotFoundError, with: :routing_error

  def show
    @property_details = Hackney::Property.find(params[:ref])
  end

  def search
    @address_list_for_postcode = Hackney::PropertyByPostcode.for_postcode(params[:ref])
  end

  private

  def routing_error
    raise ActionController::RoutingError.new('Not Found')
  end
end
