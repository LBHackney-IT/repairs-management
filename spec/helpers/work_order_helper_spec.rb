require 'rails_helper'

describe WorkOrderHelper, 'out_of_target?' do
  it 'returns true when the appointment is past the due date' do
    work_order = Hackney::WorkOrder.new(date_due: '2018-01-01T12:00:00Z')
    appointment = Hackney::Appointment.new(visit_prop_end: '2018-01-25T12:00:00Z')

    expect(
      helper.out_of_target?(work_order, appointment)
    ).to eq(true)
  end

  it 'returns false when appointment is still within the due date' do
    work_order = Hackney::WorkOrder.new(date_due: '2018-01-25T12:00:00Z')
    appointment = Hackney::Appointment.new(visit_prop_end: '2018-01-01T12:00:00Z')

    expect(
      helper.out_of_target?(work_order, appointment)
    ).to eq(false)
  end
end
