class Hackney::Appointment
  include ActiveModel::Model

  attr_accessor :visit_prop_appointment, :visit_prop_end

  def self.build(attributes)
    new(
      visit_prop_appointment: attributes['visit_prop_appointment'].to_datetime,
      visit_prop_end: attributes['visit_prop_end'].to_datetime
    )
  end
end
