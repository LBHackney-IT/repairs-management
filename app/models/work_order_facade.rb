class WorkOrderFacade
  delegate :reference, :servitor_reference, :problem_description, :latest_appointment,
           :date_due, :repair_request, :property, :created, :dlo_status,
           :work_order_status, :notes, :appointments, :reports, to: :hackney

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
    Hackney::WorkOrder.find_all(graph_work_orders.map(&:reference))
  end
end
