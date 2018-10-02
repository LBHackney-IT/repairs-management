class Hackney::WorkOrder
  include ActiveModel::Model

  attr_accessor :reference, :rq_ref, :prop_ref, :created, :date_due,
                :work_order_status, :dlo_status, :servitor_reference,
                :problem_description, :trade

  def self.find(reference)
    response = HackneyAPI::RepairsClient.new.get_work_order(reference)
    build(response)
  end

  def self.for_property(property_reference)
    HackneyAPI::RepairsClient.new.get_work_orders_by_property(property_reference).map do |attributes|
      build(attributes)
    end
  end

  def self.build(attributes)
    new(
      reference: attributes['workOrderReference'].strip,
      rq_ref: attributes['repairRequestReference'].strip,
      prop_ref: attributes['propertyReference'].strip,
      created: attributes['created'].to_datetime,
      date_due: attributes['dateDue'].to_datetime,
      work_order_status: attributes['workOrderStatus'].strip,
      dlo_status: attributes['dloStatus'].strip,
      servitor_reference: attributes['servitorReference'].strip,
      problem_description: attributes['problemDescription'],
      trade: attributes['trade']
    )
  end

  def repair_request
    @_repair_request ||= Hackney::RepairRequest.find(rq_ref)
  rescue HackneyAPI::RepairsClient::HackneyApiError => e
    Rails.logger.error(e)
    Appsignal.set_error(e, message: "Repair request not found for this work order")
    @_repair_request = Hackney::RepairRequest::NULL_OBJECT
  end

  def property
    @_property ||= Hackney::Property.find(prop_ref)
  end

  def latest_appointment
    @_latest_appointment ||= Hackney::Appointment.latest_for_work_order(reference)
  end

  def appointments
    @_appointments ||= Hackney::Appointment.all_for_work_order(reference)
  end

  def notes
    @_notes ||= Hackney::Note.for_work_order(reference)
  end
end
