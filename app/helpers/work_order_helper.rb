module WorkOrderHelper
  def out_of_target?(work_order, appointment)
    return if appointment.blank?
    work_order.date_due < appointment.begin_date
  end

  def work_order_status_description(work_order_status)
   {
     '100' => 'Collated',
     '200' => 'In Progress',
     '300' => 'Work Complete',
     '350' => 'Work Defective',
     '400' => 'Hold',
     '425' => 'Variation Outstanding',
     '450' => 'In Dispute',
     '500' => 'Approved for Statement',
     '600' => 'Statemented',
     '700' => 'Cancel Order',
     '900' => 'Complete'
   }[work_order_status]
  end

  def dlo_status_description(dlo_status)
   {
     '0' => 'Gone to Servitor',
     '1' => 'DLO Acknowledged',
     '2' => 'Job Ticket Printed',
     '3' => 'Completed',
     '6' => 'Cancelled',
     '8' => 'On Hold (i.e. Awaiting Authorisation, No Access, Awaiting Materials etc)',
     'F' => 'Off Hold'
   }[dlo_status]
  end

  def appointment_status_description(appointment_outcome)
   {
     'WA' => 'Waiting for materials',
     'CO' => 'Complete',
     'COMPLETED' => 'Complete',
     'LE' => 'Leave and return',
     'LR' => 'Leave and return',
     'LEAVE AND RETURN' => 'Leave and return',
     'IN' => 'Inspection needed',
     'EQ' => 'Complete',
     'NA' => 'No access',
     'NO' => 'No access',
     'MT' => 'Waiting for materials',
     'FO' => 'Complete',
     'PL' => 'Plant required'
   }[appointment_outcome]
  end

  def format_appointment_date(appointment)
    if appointment.begin_date.to_date ==  appointment.end_date.to_date
      "#{appointment.begin_date.to_s(:govuk_date_time)}-#{appointment.end_date.to_s(:govuk_time)}"
    else
      "#{appointment.begin_date.to_s(:govuk_date_time)} to #{appointment.end_date.to_s(:govuk_date_time)}"
    end
  end

  def format_appointment_date_short(appointment)
    if appointment.begin_date.to_date ==  appointment.end_date.to_date
      "#{appointment.begin_date.to_s(:govuk_date_time_short)}-#{appointment.end_date.to_s(:govuk_time)}"
    else
      "#{appointment.begin_date.to_s(:govuk_date_time_short)} to #{appointment.end_date.to_s(:govuk_date_time_short)}"
    end
  end

  def sort_notes_and_appointments(work_order, cache_request: true)
    notes_and_appointments = work_order.notes(cache_request: false) + (work_order.appointments.nil? ? [] : work_order.appointments)
    notes_and_appointments.sort_by{ |a| a.respond_to?(:logged_at) ? a.logged_at : a.begin_date }.reverse
  end

  def format_address(address)
    address.split("  ")
  end

  def format_caller_name(name)
    return "N/A" if (name.nil? || name.empty?)
    name.downcase.gsub(/\b('?[a-z])/) { $1.capitalize }
  end

  def appointment_status(status, outcome)
    description = appointment_status_description(outcome)
    if status == "completed" && description != "Complete"
      "#{description.nil? ? outcome : description}"
    else
      status == "Unknown" ? "Outcome unknown" : status
    end
  end

  def appointment_status_color(status, outcome)
    description = appointment_status_description(outcome)
    if status == "completed" && description != "Complete"
      "not-complete"
    elsif description == "Complete" || status == "Unknown"
      "complete"
    else
      "planned"
    end
  end
end
