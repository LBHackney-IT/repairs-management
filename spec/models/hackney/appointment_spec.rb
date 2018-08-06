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
