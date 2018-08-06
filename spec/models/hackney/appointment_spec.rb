require 'rails_helper'

describe Hackney::Appointment, '.build' do
  include Helpers::HackneyRepairsRequestStubs

  it 'builds when the API response contains all fields' do
    model = described_class.build(work_order_appointment_response_payload)

    expect(model).to be_a(Hackney::Appointment)
    expect(model.status).to eq('PLANNED')
  end

  it 'raises an error if fields are not present' do
    expect {
      described_class.build({})
    }.to raise_error(NoMethodError, "undefined method `strip' for nil:NilClass")
  end
end

describe Hackney::Appointment, '#out_of_target?' do
  include Helpers::HackneyRepairsRequestStubs

  it 'returns true when the target date is past the end date' do
    attributes = work_order_appointment_response_payload.merge(
      'endDate'    => '2018-01-02T12:00:00Z',
      'targetDate' => '2018-01-01T12:00:00Z'
    )
    model = described_class.build(attributes)

    expect(model).to be_out_of_target
  end

  it 'returns false when the target date is ahead of the end date' do
    attributes = work_order_appointment_response_payload.merge(
      'endDate'    => '2018-01-01T12:00:00Z',
      'targetDate' => '2018-01-25T12:00:00Z'
    )
    model = described_class.build(attributes)

    expect(model).to_not be_out_of_target
  end
end
