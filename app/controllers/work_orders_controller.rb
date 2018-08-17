class WorkOrdersController < ApplicationController
  rescue_from HackneyAPI::RepairsClient::RecordNotFoundError, with: :redirect_to_homepage

  helper WorkOrderHelper

  def search
    if reference.present?
      redirect_to action: :show, ref: reference
    else
      flash.notice = 'Please provide a reference'
      redirect_to root_path
    end
  end

  def show
    @page = WorkOrderPage.new(reference)
  end

private

  def redirect_to_homepage
    flash.notice = "Could not find a work order with reference #{reference}"
    redirect_to root_path
  end

  def reference
    params[:ref]
  end
end
