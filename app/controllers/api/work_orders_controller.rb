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
      property = find_and_cache_property(work_order)

      if property.is_estate?
        render 'possibly_related_for_estate'
      else
        @from = work_order.created.to_date - 6.weeks
        @to = work_order.created.to_date + 1.week

        work_orders = property.possibly_related(from: @from, to: @to)
                              .sort_by(&:created).reverse

        if work_orders.empty?
          render 'possibly_related_empty_result'
        else
          @possibly_related_to_property = work_orders.map do |wo|
            [wo, find_and_cache_property(wo)]
          end
          # render possibly_related_work_orders
        end
      end
    end

    private

    def find_and_cache_property(work_order)
      @_properties ||= {}
      @_properties[work_order.prop_ref] || Hackney::Property.find(work_order.prop_ref)
    end

    def reference
      params[:ref]
    end
  end
end
