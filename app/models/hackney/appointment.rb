class Hackney::Appointment
  include ActiveModel::Model
  include Hackney::Client

  attr_accessor :visit_prop_appointment, :visit_prop_end

  def self.build(attributes)
    new(
      visit_prop_appointment: attributes['visit_prop_appointment'].to_datetime,
      visit_prop_end: attributes['visit_prop_end'].to_datetime
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
    appointments.sort_by { |a| a.visit_prop_end }.last
  end
end
