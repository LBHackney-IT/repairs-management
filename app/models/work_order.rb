class WorkOrder
  delegate :property, :reference, :servitor_reference, :latest_appointment,
           :date_due, :repair_request, :property, :created, :dlo_status,
           :work_order_status, :notes, to: :hackney

  def initialize(reference)
    @reference = reference
  end

  def related_properties
    refs = related.map(&:property_reference).uniq
    refs.map {|prop_ref| Hackney::Property.find(prop_ref)}
  end

  def related_for_property(property)
    related.select{|wo| wo.property_reference == property.reference}
           .map{|graph_work_order| Hackney::WorkOrder.find(graph_work_order.reference) }
  end

  def related
    graph.present? ? graph.related : []
  end

  private

  def hackney
    @_hackney ||= Hackney::WorkOrder.find(@reference)
  end

  def graph
    @_graph ||= Graph::WorkOrder.find_by(id: @reference)
  end
end
