class Hackney::RepairRequest
  include ActiveModel::Model

  attr_accessor :reference, :description, :contact, :priority

  def self.build(attributes)
    new(
      reference: attributes['repairRequestReference'].strip,
      description: attributes['problemDescription'],
      contact: Hackney::Contact.build(attributes.dig('contact') || {}),
      priority: attributes['priority']
    )
  end
end
