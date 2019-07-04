class Hackney::WorkOrder
  include ActiveModel::Model

  attr_accessor :reference, :rq_ref, :prop_ref, :created, :date_due,
                :work_order_status, :dlo_status, :servitor_reference,
                :problem_description, :trade, :supplier_reference, :sor_code,
                :raised_by

  attr_accessor :quantity

  def self.find(reference)
    response = HackneyAPI::RepairsClient.new.get_work_order(reference)
    build(response)
  end

  def self.find_all(references)
    if references.any?
      response = HackneyAPI::RepairsClient.new.get_work_orders_by_references(references)
      response.map { |r| build(r) }
    else
      []
    end
  rescue HackneyAPI::RepairsClient::RecordNotFoundError => e
    Rails.logger.error(e)
    Appsignal.set_error(e, message: "Work order(s) not found")
    []
  end

  def self.feed(previous_reference)
    response = HackneyAPI::RepairsClient.new.work_order_feed(previous_reference)
    response.map { |hash| build(hash) }
  end

  def self.for_property(property_references:, date_from:, date_to:)
    HackneyAPI::RepairsClient.new.get_work_orders_by_property(
      references: property_references,
      date_from: date_from,
      date_to: date_to
    ).map do |attributes|
      build(attributes)
    end
  end

  def self.for_property_block_and_trade(property_reference:, trade:, date_from:, date_to:)
    HackneyAPI::RepairsClient.new.get_property_block_work_orders_by_trade(
      reference: property_reference,
      trade: trade,
      date_from: date_from,
      date_to: date_to
    ).map do |attributes|
      build(attributes)
    end
  end

  def self.build(attributes)
    new(
      reference: attributes['workOrderReference']&.strip,
      rq_ref: attributes['repairRequestReference']&.strip,
      prop_ref: attributes['propertyReference']&.strip,
      created: attributes['created']&.to_datetime,
      date_due: attributes['dateDue']&.to_datetime,
      work_order_status: attributes['workOrderStatus']&.strip,
      dlo_status: attributes['dloStatus']&.strip,
      servitor_reference: attributes['servitorReference']&.strip,
      problem_description: attributes['problemDescription'],
      trade: attributes['trade'],
      raised_by: attributes['username']&.strip,
      # FIXME: supplier reference naming inconsistency on API
      supplier_reference: attributes['supplierRef'] || attributes['supplierReference']
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

  def reports
    @_reports ||= Hackney::Report.for_work_order_reports(reference)
  end

  def is_dlo?
    supplier_reference.present? or raise "is_dlo?: API responded with blank supplier reference"
    !!(/\AH\d\d\z/ =~ supplier_reference)
  end
end
