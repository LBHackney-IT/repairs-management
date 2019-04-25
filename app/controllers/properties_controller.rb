class PropertiesController < ApplicationController
  include PropertyHelper
  rescue_from HackneyAPI::RepairsClient::RecordNotFoundError, with: :routing_error

  def show
    @property_details = Hackney::Property.find(params[:ref])
    @cautionary_contact = Hackney::CautionaryContact.find(@property_details.reference)
  end

  def search
    @limit = 201
    @address_list =
      if params[:ref].present?
        if is_postcode?(params[:ref])
          Hackney::Property.for_postcode(params[:ref])
        else
          Hackney::Property.for_address(params[:ref], limit: @limit)
        end
      end
  end

  private

  def routing_error
    raise ActionController::RoutingError.new('Not Found')
  end
end
