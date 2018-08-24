class Hackney::Property
  include ActiveModel::Model
  include Hackney::Client

  attr_accessor :reference, :address, :postcode

  def self.find(property_reference)
    response = client.get_property(property_reference)
    build(response)
  end

  def self.build(attributes)
    new(
      reference: attributes['propertyReference'].strip,
      address: attributes['address'],
      postcode: attributes['postcode']
    )
  end

  def work_orders
    @_work_orders ||= Hackney::WorkOrder.for_property(reference)
  end

  def hierarchy
    @_hierarchy ||= Hackney::PropertyHierarchy.for_property(reference)
  end
end
