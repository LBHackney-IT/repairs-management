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

    def possibly_related_work_orders
      work_order = Hackney::WorkOrder.find(reference)

      if work_order.property.is_estate?
        render 'possibly_related_for_estate'
      else
        @from = work_order.created.to_date - 6.weeks
        @to = work_order.created.to_date + 1.week

        @possibly_related = work_order.property
                                      .possibly_related(from: @from, to: @to)
                                      .sort_by(&:created).reverse

        render 'possibly_related_empty_result' if @possibly_related.empty?
        # render possibly_related_work_orders
      end
    end

    private

    def reference
      params[:ref]
    end
  end
end
