class Hackney::Appointment
  include ActiveModel::Model
  include Hackney::Client

  attr_accessor :begin_date, :end_date, :source_system

  def self.build(attributes)
    new(
      begin_date: attributes['beginDate'].to_datetime,
      end_date: attributes['endDate'].to_datetime,
      source_system: attributes['sourceSystem']
    )
  end

  def self.latest_for_work_order(work_order_reference)
    response = begin
      client.get_work_order_appointments(work_order_reference)
    rescue HackneyAPI::RepairsClient::RecordNotFoundError
      [] # Ewww... the api currently returns 404 for no appointments... so patch it like this until the api is more sensible
    end

    appointments = response.map do |attributes|
      Hackney::Appointment.build(attributes)
    end
    appointments.sort_by { |a| a.end_date }.last
  end
end
