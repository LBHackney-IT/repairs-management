class WorkOrdersController < ApplicationController
  rescue_from HackneyAPI::RepairsClient::RecordNotFoundError, with: :redirect_to_homepage
  rescue_from HackneyAPI::RepairsClient::ApiError, with: :redirect_to_homepage

  helper WorkOrderHelper

  def search
    if reference.present?
      redirect_to action: :show, ref: reference
    else
      flash.notice = 'Please provide a reference or postcode'
      redirect_to root_path
    end
  end

  def show
    if is_work_order(reference)
      @work_order = Hackney::WorkOrder.find(reference)
    else
      @address_list_for_postcode = Hackney::Property.for_postcode(reference)
      if @address_list_for_postcode.present?
        render 'pages/home'
      else
        redirect_to_homepage
      end
    end
  end

private

  def redirect_to_homepage
    if is_work_order(reference)
      flash.notice = "Could not find a work order with reference #{reference}"
    elsif is_postcode(reference)
      flash.notice = "Could not find the property with postcode #{reference}"
    else
      flash.notice = "Could not find any results matching #{reference}"
    end
    redirect_to root_path
  end

  def reference
    params[:ref].gsub(/\s+/, "")
  end

  def is_work_order(reference)
    reference[/\d{8}/]
  end

  def is_postcode(postcode)
    postcode.upcase[/^[A-Z]{1,2}([0-9]{1,2}|[0-9][A-Z])\s*[0-9][A-Z]{2}$/]
  end
end
