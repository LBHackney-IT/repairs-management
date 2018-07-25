class WorkOrdersController < ApplicationController
  def search
    if params[:ref].present?
      redirect_to action: :show, ref: params[:ref]
    else
      flash.notice = 'Please provide a reference'
      redirect_to root_path
    end
  end

  def show
    @work_order = WorkOrder.find_by(ref: params[:ref])

    if @work_order.blank?
      flash.notice = "Could not find a work order with reference #{params[:ref]}"
      redirect_to root_path
    end
  end
end
