class Hackney::Appointment
  include ActiveModel::Model

  attr_accessor :begin_date, :end_date, :source_system, :priority,
                :comment, :status, :phone_number, :reported_on, :assigned_worker

  def self.build(attributes)
    new(
      begin_date: attributes['beginDate']&.to_datetime,
      end_date: attributes['endDate']&.to_datetime,
      source_system: attributes['sourceSystem'],
      priority: attributes['priority'],
      comment: attributes['comment'],
      status: attributes['status'],
      phone_number: attributes['phonenumber'],
      reported_on: attributes['creationDate']&.to_datetime,
      assigned_worker: attributes['assignedWorker']
    )
  end

  def self.latest_for_work_order(work_order_reference)
    response = HackneyAPI::RepairsClient.new.get_work_order_appointments_latest(work_order_reference)
    build(response)
  rescue HackneyAPI::RepairsClient::RecordNotFoundError
    nil
  end
end
