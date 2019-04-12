class Hackney::RepairRequest
  include ActiveModel::Model

  attr_accessor :reference, :description, :contact, :priority, :work_orders, :property_reference

  NULL_OBJECT = self.new(description: 'Repair info missing')

  PRIORITIES = (?A..?P).to_a + %w(P1 P2 P3) + (?Q..?Z).to_a
  RAISABLE_PRIORITIES = %w(E I K O U V N L)

  def self.find(repair_request_reference)
    response = HackneyAPI::RepairsClient.new.get_repair_request(repair_request_reference)
    build(response)
  end

  # TODO: improve naming
  def self.build(attributes)
    new(attributes_from_api(attributes))
  end

  # FIXME: this is view logic and shouldn't be here
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
    self.attributes = self.class.attributes_from_api(response)
    true
  rescue HackneyAPI::RepairsClient::ApiError => e
    self.class.errors_from_api(e.errors).each do |key, list|
      list.each do |msg|
        errors.add(key, msg)
      end
    end
    add_nested_errors
    false
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

  private

  # TODO: API should give better error descriptions
  def add_nested_errors
    errors.each do |key, msg|
      case key
      when /^contact\.(.*)$/i
        contact.errors.add($1, msg)
      when /^work_orders\[0\]\.(.*)$/i
        work_orders[0].errors.add($1, msg)
      end
    end
  end

  # TODO: API should give better error descriptions
  def self.errors_from_api(response)
    response.map {|x| x["userMessage"] }.group_by do |x|
      case x
      when /Telephone/i
        "contact.telephone_number"
      when /Contact Name/i
        "contact.name"
      when /Problem/i
        "description"
      when /sorCode/i
        "work_orders[0].sor_code"
      else
        "base"
      end
    end
  end
end
