class WorkOrders::CancellationsController < ApplicationController
  before_action :set_work_order

  def new
    @cancellation = build_cancellation
  end

  def create
    @cancellation = build_cancellation(cancellation_params)

    respond_to do |format|
      if @cancellation.save
        format.html { render :created }
      else
        flash.now[:error] = @cancellation.errors["base"]
        format.html { render :new }
      end
    end
  end

  private

  def build_cancellation attributes = {}
    Hackney::WorkOrder::Cancellation.new(attributes).tap do |c|
      c.work_order_reference = params[:work_order_ref]
      c.created_by_email = current_user_email
    end
  end

  def cancellation_params
    params.require(:hackney_work_order_cancellation).permit(:reason)
  end

  def set_work_order
    @work_order = Hackney::WorkOrder.find(params[:work_order_ref])
  end
end
