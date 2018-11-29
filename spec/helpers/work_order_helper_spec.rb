require 'rails_helper'

describe WorkOrderHelper, 'out_of_target?' do
  it 'returns true when the appointment is past the due date' do
    work_order = Hackney::WorkOrder.new(date_due: '2018-01-01T12:00:00Z')
    appointment = Hackney::Appointment.new(begin_date: '2018-01-25T12:00:00Z')

    expect(
      helper.out_of_target?(work_order, appointment)
    ).to eq(true)
  end

  it 'returns false when appointment is still within the due date' do
    work_order = Hackney::WorkOrder.new(date_due: '2018-01-25T12:00:00Z')
    appointment = Hackney::Appointment.new(begin_date: '2018-01-01T12:00:00Z')

    expect(
      helper.out_of_target?(work_order, appointment)
    ).to eq(false)
  end
end

describe WorkOrderHelper, 'sort_notes_and_appointments' do
  it "sorts the notes and appointments by start date" do
    appointment = Hackney::Appointment.new(begin_date: 7.days.ago)
    appointment_two = Hackney::Appointment.new(begin_date: 5.days.ago)
    note = Hackney::Note.new(logged_at: 3.days.ago)

    work_order = double(notes: [note], appointments: [appointment, appointment_two])
    cache_request = true

    sorted = [note, appointment_two, appointment]
    expect(helper.sort_notes_and_appointments(work_order, cache_request)).to eq(sorted)
  end
end
