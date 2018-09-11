class WorkOrdersController < ApplicationController
  rescue_from HackneyAPI::RepairsClient::RecordNotFoundError, with: :redirect_to_homepage

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
    if is_work_order?(reference)
      @work_order = WorkOrder.new(reference)
    elsif is_postcode?(reference)
      redirect_to search_properties_path(ref: reference)
    else
      flash.notice = "#{reference} is not a valid work order or postcode"
      redirect_to root_path
    end
  end

private

  def redirect_to_homepage
    flash.notice = "Could not find a work order with reference #{reference}"
    redirect_to root_path
  end

  def reference
    params[:ref].gsub(/\s+/, "")
  end

  def is_work_order?(reference)
    reference[/\A\d{8}\z/]
  end

  def is_postcode?(postcode)
    postcode.upcase[/^[A-Z]{1,2}([0-9]{1,2}|[0-9][A-Z])[0-9][A-Z]{2}$/]
  end
end
