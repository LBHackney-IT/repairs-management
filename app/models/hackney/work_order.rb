class Hackney::WorkOrder
  include ActiveModel::Model

  attr_accessor :reference, :rq_ref, :prop_ref, :created, :date_due, :u_status_desc

  def self.build(attributes)
    new(
      reference: attributes['wo_ref'].strip,
      rq_ref: attributes['rq_ref'].strip,
      prop_ref: attributes['prop_ref'].strip,
      created: attributes['created'].to_datetime,
      date_due: attributes['date_due'].to_datetime,
      u_status_desc: attributes['u_status_desc'].strip
    )
  end
end
