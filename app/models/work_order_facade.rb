class WorkOrderFacade
  delegate :property, :reference, :servitor_reference, :latest_appointment,
           :date_due, :repair_request, :property, :created, :dlo_status,
           :work_order_status, :notes, :appointments, to: :hackney

  def initialize(reference)
    @reference = reference
  end

  def related_properties
    refs = related.map(&:prop_ref).uniq
    refs.map {|prop_ref| Hackney::Property.find(prop_ref)}
  end

  def related_for_property(property)
    related.select{|wo| wo.prop_ref == property.reference}
  end

  def related
    @_related ||= if graph.present?
                    convert_graph_work_orders(graph.related)
                  else
                    []
                  end
  end

  private

  def hackney
    @_hackney ||= Hackney::WorkOrder.find(@reference)
  end

  def graph
    @_graph ||= Graph::WorkOrder.find_by(id: @reference)
  end

  def convert_graph_work_orders(graph_work_orders)
    # TODO: use the multi id fetch when ready instead of one by one
    graph_work_orders.map do |graph_work_order|
      Hackney::WorkOrder.find(graph_work_order.reference)
    rescue Exception => e
      Rails.logger.error("Unable to find work order #{graph_work_order.reference} in API: #{e.message}")
      Appsignal.set_error(e)
      nil
    end.compact
  end
end
