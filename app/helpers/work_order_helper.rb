module WorkOrderHelper
  def out_of_target?(work_order, appointment)
    work_order.date_due < appointment.visit_prop_appointment
  end
end
