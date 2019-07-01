class Hackney::WorkOrder::Cancellation
  include ActiveModel::Model

  attr_accessor :work_order_reference, :created_by_email, :reason

  def to_param
    work_order_reference
  end

  def save
    api = HackneyAPI::RepairsClient.new
    api.cancel_work_order(work_order_reference, created_by_email)
    api.post_work_order_note(
      work_order_reference,
      "Cancelled in Repairs Hub: #{reason}",
      created_by_email
    )
    true
  end
end
