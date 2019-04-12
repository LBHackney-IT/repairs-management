class Hackney::RepairRequest
  include ActiveModel::Model

  attr_accessor :reference, :description, :contact, :priority, :work_orders, :property_reference

  NULL_OBJECT = self.new(description: 'Repair info missing')

  PRIORITIES = {
    "A" => "ASBESTOS SURVEY",
    "B" => "FRA WORKS",
    "C" => "GAS-NEW BOILER INST",
    "D" => "GAS-NEW HTG INST",
    "E" => "2 [E] EMERGENCY",
    "F" => "LIFTS - PL MAINT",
    "G" => "GAS SERVICING",
    "H" => "GAS - CARCASS TEST",
    "I" => "1 [I] IMMEDIATE",
    "J" => "INSTALLATION DOORS",
    "K" => "3 [K] RTR 3 DAYS",
    "L" => "8 [L] LEGAL DISREP",
    "M" => "[M] CYC MAINT 365 DA",
    "N" => "5 [N] NORMAL",
    "O" => "7 [O] OUT OF HOURS",
    "P" => "9 [P] PLANNED MAINT",
    "P1" => "[P1] New Build 1 Day",
    "P2" => "[P2] New Bld 7 Days",
    "P3" => "[P3] New Bld 28 Days",
    "Q" => "VOID - 3 WORK DAYS",
    "R" => "ELECTRICAL PLANS",
    "S" => "LIFT CTR PLANS",
    "T" => "VOIDS NON-REP 2 DAYS",
    "U" => "4 [U] URGENT",
    "V" => "6 [V] VOID REPAIRS",
    "W" => "10[W] WATER QUALITY",
    "X" => "GAS - EXTRA WORK",
    "Y" => "VOID - 10 WKG DAYS",
    "Z" => "VOIDS INITIATIVE",
  }

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
