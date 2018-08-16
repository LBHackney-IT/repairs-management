module WorkOrderHelper
  def out_of_target?(work_order, appointment)
    return if appointment.blank?
    work_order.date_due < appointment.visit_prop_appointment
  end
end
