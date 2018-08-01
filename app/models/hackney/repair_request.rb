class Hackney::RepairRequest
  include ActiveModel::Model

  attr_accessor :reference, :description, :contact

  def self.build(attributes)
    new(
      reference: attributes['repairRequestReference'].strip,
      description: attributes['problemDescription'],
      contact: Hackney::Contact.build(attributes.dig('contact') || {})
    )
  end
end
