class Hackney::Supplier
  include ActiveModel::Model

  attr_accessor :supplier_reference

  def self.build(attributes)
    new(
      supplier_reference: attributes['supplierRef']
    )
  end
end
