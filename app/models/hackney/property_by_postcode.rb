class Hackney::PropertyByPostcode
  include ActiveModel::Model

  attr_accessor :reference, :level_code, :description, :major_reference, :address, :postcode

  def self.for_postcode(postcode)
    HackneyAPI::RepairsClient.new.get_property_by_postcode(postcode)["results"].map do |attributes|
      build(attributes)
    end
  end

  def self.build(attributes)
    new(
      reference: attributes['propertyReference'].strip,
      level_code: attributes['levelCode'],
      description: attributes['description'],
      major_reference: attributes['majorReference'],
      address: attributes['address'],
      postcode: attributes['postcode']
    )
  end
end
