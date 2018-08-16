class WorkOrderPage
  attr_reader :work_order, :repair_request, :contact, :property, :latest_appointment

  def initialize(work_order_reference)
    @work_order_reference = work_order_reference

    build_work_order
    build_repair_request
    build_property
    build_appointment
  end

  private

  def build_work_order
    response = client.get_work_order(@work_order_reference)
    @work_order = Hackney::WorkOrder.build(response)
  end

  def build_repair_request
    response = client.get_repair_request(repair_request_reference)
    @repair_request = Hackney::RepairRequest.build(response)
    @contact = @repair_request.contact
  end

  def build_property
    response = client.get_property(property_reference)
    @property = Hackney::Property.build(response)
  end

  def build_appointment
    response = client.get_work_order_appointments(@work_order_reference)
    appointments = response.map do |attributes|
      Hackney::Appointment.build(attributes)
    end
    @latest_appointment = appointments.sort_by{|a| a.visit_prop_end}.last
  end

  def client
    @_client ||= HackneyRepairsClient.new
  end

  def repair_request_reference
    @work_order.rq_ref
  end

  def property_reference
    @work_order.prop_ref
  end
end
