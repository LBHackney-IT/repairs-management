class WorkOrdersController < ApplicationController
  rescue_from HackneyAPI::RepairsClient::RecordNotFoundError, with: :redirect_to_homepage

  helper WorkOrderHelper

  def search
    if reference.present?
      if is_work_order?(reference)
        redirect_to action: :show, ref: reference
      else
        redirect_to search_properties_path(ref: params[:ref])
      end
    else
      flash.notice = ['Please provide a reference, postcode or address']
      redirect_to root_path
    end
  end

  def show
    @work_order = WorkOrderFacade.new(reference)
    @cautionary_contacts = Hackney::CautionaryContact.find_by_property_reference(@work_order.property.reference)
  end

private

  def redirect_to_homepage
    flash.notice = ["Could not find a work order with reference #{reference}"]
    redirect_to root_path
  end

  def query
    params[:ref].to_s
  end

  def reference
    query.gsub(/\s+/, "")
  end

  def is_work_order?(s)
    s[/\A\d{8}\z/]
  end
end
