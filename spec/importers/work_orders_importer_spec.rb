require 'rails_helper'

describe WorkOrdersImporter, '#import', :db_connection do
  it 'imports new work orders' do
    api_response = {
      'data' => [
        {
          'type' => 'work_order',
          'id' => '01572924',
          'attributes' => {
            'repair_request_reference' => '03249135'
          }
        },
        {
          'type' => 'work_order',
          'id' => '06183523',
          'attributes' => {
            'repair_request_reference' => '03174913'
          }
        }
      ]
    }.to_json

    stub_request(:get, "https://hackneyrepairs/v1/workorders")
      .to_return(body: api_response)

    expect(WorkOrder.count).to eq(0)

    WorkOrdersImporter.new.import

    expect(WorkOrder.count).to eq(2)
    expect(WorkOrder.all.map(&:ref)).to contain_exactly('06183523', '01572924')
  end
end
