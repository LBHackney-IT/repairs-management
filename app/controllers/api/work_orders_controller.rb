module Api
  class WorkOrdersController < Api::ApiController
    def description
      @work_order = Hackney::WorkOrder.find(reference)
    end

    def notes_and_appointments
      @work_order = Hackney::WorkOrder.find(reference)
    end

    def documents
      @reports = Hackney::WorkOrder.find(reference).reports
    end

    def repairs_history
      @work_order = Hackney::WorkOrder.find(reference)
    end

    def related_work_orders
      @work_order = WorkOrderFacade.new(reference)
    end

    private

    def reference
      params[:ref]
    end
  end
end
