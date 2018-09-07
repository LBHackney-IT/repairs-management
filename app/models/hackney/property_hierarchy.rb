class Hackney::PropertyHierarchy
  include ActiveModel::Model
  include Hackney::Client

  attr_accessor :reference, :level_code, :description, :major_reference, :address, :postcode

  def self.for_property(reference)
    client.get_property_hierarchy(reference).map do |attributes|
      build(attributes)
    end
  end

  def self.build(attributes)
    # TODO: remove strip from attributes['attr'].strip - API should be fixed soon
    new(
      reference: attributes['propertyReference']&.strip,
      level_code: attributes['levelCode'],
      description: attributes['description']&.strip,
      major_reference: attributes['majorReference']&.strip,
      address: attributes['address']&.strip,
      postcode: attributes['postCode']&.strip
    )
  end
end
