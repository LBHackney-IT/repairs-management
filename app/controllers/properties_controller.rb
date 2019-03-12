class PropertiesController < ApplicationController
  rescue_from HackneyAPI::RepairsClient::RecordNotFoundError, with: :routing_error

  def show
    @property_details = Hackney::Property.find(params[:ref])
  end

  def search
    if params[:ref].present?
      @address_list_for_postcode = Hackney::Property.for_postcode(params[:ref])
    elsif params[:addr].present?
      @address_list_for_postcode = Hackney::Property.for_address(params[:addr])
    end
  end

  private

  def routing_error
    raise ActionController::RoutingError.new('Not Found')
  end
end
