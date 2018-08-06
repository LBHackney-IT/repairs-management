class Hackney::WorkOrder
  include ActiveModel::Model
  include Hackney::Client

  attr_accessor :reference, :rq_ref, :prop_ref, :created, :date_due,
                :work_order_status, :dlo_status, :servitor_reference

  def self.find(reference)
    response = client.get_work_order(reference)
    build(response)
  end

  def self.for_property(property_reference)
    work_orders = client.get_work_orders_by_property(property_reference)
      .map do |attributes|
      build(attributes)
    end

    repairs_map = repair_request_map(property_reference)

    work_orders.each do |work_order|
      work_order.repair_request = repairs_map[work_order.rq_ref]
    end

    work_orders
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
    )
  end

  def repair_request
    @_repair_request ||= Hackney::RepairRequest.find(rq_ref)
  rescue HackneyAPI::RepairsClient::HackneyApiError => e
    Rails.logger.error(e)
    @_repair_request = Hackney::RepairRequest::NULL_OBJECT
  end

  def repair_request=(repair_request)
    @_repair_request = repair_request
  end

  def property
    @_property ||= Hackney::Property.find(prop_ref)
  end

  def latest_appointment
    @_latest_appointment ||= Hackney::Appointment.latest_for_work_order(reference)
  end

  def notes
    @_notes ||= Hackney::Note.for_work_order(reference)
  end

  class << self
    private

    def repair_request_map(property_reference)
      repair_requests = Hash.new(Hackney::RepairRequest::NULL_OBJECT)

      client.get_repair_requests_by_property(property_reference).each do |rr|
        repair_request = Hackney::RepairRequest.build(rr)
        repair_requests[repair_request.reference] = repair_request
      end

      repair_requests
    end
  end
end
