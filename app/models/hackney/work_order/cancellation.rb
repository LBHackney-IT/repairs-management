class Hackney::WorkOrder::Cancellation
  include ActiveModel::Model

  attr_accessor :work_order_reference, :created_by_email, :reason

  validates :reason, presence: true

  def to_param
    work_order_reference
  end

  def save
    valid? or return false

    api = HackneyAPI::RepairsClient.new
    api.cancel_work_order(work_order_reference, created_by_email)
    api.post_work_order_note(
      work_order_reference,
      "Cancelled in Repairs Hub: #{reason}",
      created_by_email
    )
    true

  rescue HackneyAPI::RepairsClient::TimeoutError => e
    # FIXME: this is duplicated in RepairRequest
    errors.add("base", "The Hackney API timed out. Please, contact the development team.")
    false

  rescue HackneyAPI::RepairsClient::ApiError => e
    # ensure we always have an array
    [e.errors].flatten.each do |x|
      # try hard to get a message
      errors.add("base", x["message"] || x["userMessage"] || x["developerMessage"])
    end
    false
  end
end
