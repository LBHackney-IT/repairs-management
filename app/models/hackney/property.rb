class Hackney::Property
  include ActiveModel::Model

  attr_accessor :reference, :address, :postcode

  def self.build(attributes)
    new(
      reference: attributes['propertyReference'].strip,
      address: attributes['address'],
      postcode: attributes['postcode']
    )
  end
end
