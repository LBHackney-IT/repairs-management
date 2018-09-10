require 'rails_helper'

describe Hackney::Appointment, '.build' do
  include Helpers::HackneyRepairsRequestStubs

  it 'builds when the API response contains all fields' do
    model = described_class.build(
      "beginDate" => "2018-05-30T08:00:00",
      "endDate" => "2018-05-30T12:00:00",
      "sourceSystem" => "DRS"
    )

    expect(model).to be_a(Hackney::Appointment)
    expect(model.end_date).to eq(DateTime.new(2018, 05, 30, 12, 00, 00))
  end
end
