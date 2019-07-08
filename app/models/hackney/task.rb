class Hackney::Task
  include ActiveModel::Model

  # FIXME: Task and WorkOrder are somewhat mixed in the API

  attr_accessor :sor_code
  attr_accessor :sor_code_description
  attr_accessor :trade
  attr_accessor :work_order_reference
  attr_accessor :repair_request_reference
  attr_accessor :problem_description
  attr_accessor :created_at
  attr_accessor :auth_date
  attr_accessor :estimated_cost
  attr_accessor :actual_cost
  attr_accessor :completed_at
  attr_accessor :date_due
  attr_accessor :work_order_status
  attr_accessor :dlo_status
  attr_accessor :servitor_reference
  attr_accessor :property_reference
  attr_accessor :supplier_reference
  attr_accessor :user_login
  attr_accessor :user_name
  attr_accessor :authorised_by
  attr_accessor :estimated_units
  attr_accessor :unit_type
  attr_accessor :status

  def self.for_work_order(work_order_reference)
    HackneyAPI::RepairsClient
      .new
      .get_work_order_tasks(work_order_reference)
      .map { |api_attributes| new_from_api(api_attributes) }
  end

  def self.new_from_api(api_attributes)
    new(attributes_from_api(api_attributes))
  end

  def is_dlo?
    supplier_reference.present? or raise "is_dlo?: API responded with blank supplier reference"
    !!(/\AH\d\d\z/ =~ supplier_reference)
  end

  private

  def self.attributes_from_api(api_attributes)
    stripped = api_attributes.transform_values {|v| v.try(:strip) || v }

    {
      sor_code:                 api_attributes["sorCode"],
      sor_code_description:     api_attributes["sorCodeDescription"],
      trade:                    api_attributes["trade"],
      work_order_reference:     api_attributes["workOrderReference"],
      repair_request_reference: api_attributes["repairRequestReference"],
      problem_description:      api_attributes["problemDescription"],
      created_at:               api_attributes["created"]&.to_datetime,
      auth_date:                api_attributes["authDate"]&.to_datetime,
      estimated_cost:           api_attributes["estimatedCost"],
      actual_cost:              api_attributes["actualCost"],
      completed_at:             api_attributes["completedOn"]&.to_datetime,
      date_due:                 api_attributes["dateDue"]&.to_datetime,
      work_order_status:        api_attributes["workOrderStatus"],
      dlo_status:               api_attributes["dloStatus"],
      servitor_reference:       api_attributes["servitorReference"],
      property_reference:       api_attributes["propertyReference"],
      supplier_reference:       api_attributes["supplierRef"],
      user_login:               api_attributes["userLogin"],
      user_name:                api_attributes["username"],
      authorised_by:            api_attributes["authorisedBy"],
      estimated_units:          api_attributes["EstimatedUnits"],
      status:                   api_attributes["taskStatus"],
      unit_type:                api_attributes["unitType"],
    }
  end
end
