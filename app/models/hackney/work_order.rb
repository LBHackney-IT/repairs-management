class Hackney::WorkOrder
  include ActiveModel::Model

  # FIXME: Task and WorkOrder are somewhat mixed in the API

  attr_accessor :sor_code
  attr_accessor :sor_code_description
  attr_accessor :trade
  attr_accessor :reference
  attr_accessor :rq_ref
  attr_accessor :problem_description
  attr_accessor :created
  attr_accessor :auth_date
  attr_accessor :estimated_cost
  attr_accessor :actual_cost
  attr_accessor :completed_on
  attr_accessor :date_due
  attr_accessor :work_order_status
  attr_accessor :dlo_status
  attr_accessor :servitor_reference
  attr_accessor :prop_ref
  attr_accessor :supplier_reference
  attr_accessor :raised_by
  attr_accessor :user_name
  attr_accessor :authorised_by

  def self.find(reference)
    response = HackneyAPI::RepairsClient.new.get_work_order(reference)
    new_from_api(response)
  end

  def self.find_all(references)
    if references.any?
      response = HackneyAPI::RepairsClient.new.get_work_orders_by_references(references)
      response.map { |r| new_from_api(r) }
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
    response.map { |hash| new_from_api(hash) }
  end

  def self.for_property(property_references:, date_from:, date_to:)
    HackneyAPI::RepairsClient.new.get_work_orders_by_property(
      references: property_references,
      date_from: date_from,
      date_to: date_to
    ).map do |attributes|
      new_from_api(attributes)
    end
  end

  def self.for_property_block_and_trade(property_reference:, trade:, date_from:, date_to:)
    HackneyAPI::RepairsClient.new.get_property_block_work_orders_by_trade(
      reference: property_reference,
      trade: trade,
      date_from: date_from,
      date_to: date_to
    ).map do |attributes|
      new_from_api(attributes)
    end
  end

  def self.new_from_api(api_attributes)
    new(attributes_from_api(api_attributes))
  end

  # FIXME: bad naming
  def self.build(api_attributes)
    new_from_api(api_attributes)
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

  def tasks
    @tasks ||= Hackney::Task.for_work_order(reference)
  end

  private

  def self.attributes_from_api(api_attributes)
    # FIXME: is this still necessary?
    stripped = api_attributes
      .map {|k, v| [k, v.try(:strip) || v] }
      .to_h

    {
      sor_code:                 api_attributes["sorCode"],
      sor_code_description:     api_attributes["sorCodeDescription"],
      trade:                    api_attributes["trade"],
      reference:                api_attributes["workOrderReference"],
      rq_ref:                   api_attributes["repairRequestReference"],
      problem_description:      api_attributes["problemDescription"],
      created:                  api_attributes["created"]&.to_datetime,
      auth_date:                api_attributes["authDate"]&.to_datetime,
      estimated_cost:           api_attributes["estimatedCost"],
      actual_cost:              api_attributes["actualCost"],
      completed_on:             api_attributes["completedOn"],
      date_due:                 api_attributes["dateDue"]&.to_datetime,
      work_order_status:        api_attributes["workOrderStatus"],
      dlo_status:               api_attributes["dloStatus"],
      servitor_reference:       api_attributes["servitorReference"],
      prop_ref:                 api_attributes["propertyReference"],
      supplier_reference:       api_attributes["supplierRef"],
      raised_by:                api_attributes["userLogin"],
      user_name:                api_attributes["username"],
      authorised_by:            api_attributes["authorisedBy"],
    }
  end
end
