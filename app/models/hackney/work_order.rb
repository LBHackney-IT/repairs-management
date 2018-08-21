class Hackney::WorkOrder
  include ActiveModel::Model

  attr_accessor :reference, :rq_ref, :prop_ref, :created, :date_due,
                :work_order_status, :dlo_status, :servitor_reference

  def self.build(attributes)
    new(
      reference: attributes['workOrderReference'].strip,
      rq_ref: attributes['repairRequestReference'].strip,
      prop_ref: attributes['propertyReference'].strip,
      created: attributes['created'].to_datetime,
      date_due: attributes['dateDue'].to_datetime,
      work_order_status: attributes['workOrderStatus'].strip,
      dlo_status: attributes['dloStatus'].strip,
      servitor_reference: attributes['servitorReference'].strip,
    )
  end
end
