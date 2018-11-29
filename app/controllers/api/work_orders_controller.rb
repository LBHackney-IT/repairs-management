module Api
  class WorkOrdersController < Api::ApiController
    def description
      @work_order = Hackney::WorkOrder.find(reference)
    end

    def notes_and_appointments
      @work_order = Hackney::WorkOrder.find(reference)

      @notes_and_appointments = @work_order.notes(true) + (@work_order.appointments.nil? ? [] : @work_order.appointments)
    end

    def notes
      @work_order = Hackney::WorkOrder.find(reference)

      @notes_and_appointments = @work_order.notes(false) + (@work_order.appointments.nil? ? [] : @work_order.appointments)

      if !params[:note][:text].blank?
        Hackney::Note.create_work_order_note(reference, params[:note][:text])

        render 'notes_and_appointments'
      end
    end

    def documents
      @reports = Hackney::WorkOrder.find(reference).reports
    end

    def related_work_orders
      @work_order = WorkOrderFacade.new(reference)
    end

    def possibly_related_work_orders
      work_order = Hackney::WorkOrder.find(reference)
      property = work_order.property

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
          properties = Hackney::Property.find_all(work_orders.map(&:prop_ref).uniq)

          @possibly_related_to_property = work_orders.map do |wo|
            [wo, find_matching_property(wo, properties)]
          end
          # render possibly_related_work_orders
        end
      end
    end

    private

    def find_matching_property(work_order, properties)
      properties.find { |property| property.reference == work_order.prop_ref }
    end

    def reference
      params[:ref]
    end
  end
end
