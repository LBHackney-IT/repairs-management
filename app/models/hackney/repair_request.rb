class Hackney::RepairRequest
  include ActiveModel::Model

  attr_accessor :reference, :description, :contact, :priority, :work_orders, :property_reference

  NULL_OBJECT = self.new(description: 'Repair info missing')

  def self.find(repair_request_reference)
    response = HackneyAPI::RepairsClient.new.get_repair_request(repair_request_reference)
    build(response)
  end

  # TODO: improve naming
  def self.build(attributes)
    new(attributes_from_api(attributes))
  end

  def telephone_number
    contact&.telephone_number.blank? ? "N/A" : contact&.telephone_number
  end

  def contact_name
    contact&.name
  end

  #
  # persistence
  #
  def work_orders_attributes=(a)
    a = a.values if a.is_a?(Hash)
    self.work_orders = a.map {|x| Hackney::WorkOrder.new(x)}
  end

  def contact_attributes=(a)
    self.contact = Hackney::Contact.new(a)
  end

  def save
    response = HackneyAPI::RepairsClient.new.post_repair_request(
      name: contact_name,
      phone: telephone_number,
      sor_code: work_orders&.first&.sor_code,
      priority: priority,
      property_ref: property_reference,
      description: description
    )

    response.present? or raise "*** API ERROR SAVING REPAIR REQUEST. response: #{response} ***" # TODO
    self.attributes = self.class.attributes_from_api(response)
  end

  #
  # read attributes from API
  #

  def self.attributes_from_api(a)
    {
      reference: a['repairRequestReference']&.strip,
      description: a['problemDescription'],
      contact: Hackney::Contact.build(a['contact'] || {}),
      priority: a['priority'],
      work_orders: (a['workOrders'] || []).map {|y| Hackney::WorkOrder.build(y)},
      property_reference: a['propertyReference']
    }
  end
end
