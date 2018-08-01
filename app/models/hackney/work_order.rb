class Hackney::WorkOrder
  include ActiveModel::Model

  attr_accessor :reference, :rq_ref, :prop_ref, :created

  def self.build(attributes)
    new(
      reference: attributes['wo_ref'].strip,
      rq_ref: attributes['rq_ref'].strip,
      prop_ref: attributes['prop_ref'].strip,
      created: (attributes['created'].to_datetime rescue nil)
    )
  end
end
