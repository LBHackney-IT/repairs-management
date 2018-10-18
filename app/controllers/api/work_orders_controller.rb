module Api
  class WorkOrdersController < Api::ApiController
    def description
      @work_order = Hackney::WorkOrder.find(reference)
    end

    def notes_and_appointments
      @work_order = Hackney::WorkOrder.find(reference)
    end

    def work_order_documents
      @reports = Hackney::WorkOrder.find(reference).reports
    end

    private

    def reference
      params[:ref]
    end
  end
end
