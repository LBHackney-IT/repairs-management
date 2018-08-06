class Hackney::RepairRequest
  include ActiveModel::Model
  include Hackney::Client

  attr_accessor :reference, :description, :contact, :priority

  NULL_OBJECT = self.new(description: 'Repair info missing')

  def self.find(repair_request_reference)
    response = client.get_repair_request(repair_request_reference)
    build(response)
  end

  def self.build(attributes)
    new(
      reference: attributes['repairRequestReference'].strip,
      description: attributes['problemDescription'],
      contact: Hackney::Contact.build(attributes.dig('contact') || {}),
      priority: attributes['priority']
    )
  end
end
