class PropertiesController < ApplicationController
  rescue_from HackneyAPI::RepairsClient::RecordNotFoundError, with: :redirect_to_homepage

  def show
    @property_details = property_details
  end

  private

  def property_details
    Hackney::Property.find(params[:ref])
  end

  def postcode
    property_details.postcode
  end

  def address
    property_details.address
  end

  def redirect_to_homepage
    flash.notice = "There are no work orders for the property at #{address}"
    redirect_to root_path + "work_orders/#{postcode}"
  end
end

