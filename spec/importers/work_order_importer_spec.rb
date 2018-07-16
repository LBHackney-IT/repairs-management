require 'rails_helper'

describe WorkOrderImporter, '#import' do
  it 'imports new work orders' do
    allow(ENV).to receive(:has_key?).with('http_proxy').and_return(true)

    api_response = {
      'data' => [
        {
          'type' => 'work_order',
          'id' => '01572924',
          'attributes' => {
            'status' => 'Complete'
          }
        },
        {
          'type' => 'work_order',
          'id' => '06183523',
          'attributes' => {
            'status' => 'Appointment booked'
          }
        }
      ]
    }.to_json

    stub_request(:get, "https://hackneyrepairs/v1/workorders")
      .to_return(body: api_response)

    expect(WorkOrder.count).to eq(0)

    WorkOrderImporter.new.import

    expect(WorkOrder.count).to eq(2)
    expect(WorkOrder.all.map(&:ref)).to contain_exactly('06183523', '01572924')
  end
end
