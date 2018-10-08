module Api
  class WorkOrdersController < Api::ApiController
    layout :false

    def description
      @work_order = Hackney::WorkOrder.find(reference)
    end

    private

    def reference
      params[:ref]
    end
  end
end
