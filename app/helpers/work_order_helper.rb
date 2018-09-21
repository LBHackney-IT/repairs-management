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

  def trade_index(property, trade)
    property.trades.index(trade)
  end

  def format_appointment_date(appointment)
    if appointment.begin_date.to_date ==  appointment.end_date.to_date
      "#{appointment.begin_date.to_s(:govuk_date_time)} to #{appointment.end_date.to_s(:govuk_time)}"
    else
      "#{appointment.begin_date.to_s(:govuk_date_time)} to #{appointment.end_date.to_s(:govuk_date_time)}"
    end
  end

  def sort_notes_and_appointments(work_order)
    notes_and_appointments = work_order.notes + (work_order.appointments.nil? ? [] : work_order.appointments)
    notes_and_appointments.sort_by{ |a| a.respond_to?(:logged_at) ? a.logged_at : a.begin_date }.reverse
  end
end
