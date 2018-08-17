require 'rails_helper'

describe WorkOrdersImporter, :db_connection do
  let(:service_instance) { described_class.new }
  let(:api_response) do
    {
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
    }
  end

  describe '#import' do
    subject { service_instance.import }

    before { stub_request(:get, "#{ENV['HACKNEY_REPAIRS_API_BASE_URL']}/v1/work_orders")
      .to_return(body: api_response.to_json)
    }

    it 'imports new work orders' do
      expect(WorkOrder.count).to eq(0)
      subject
      expect(WorkOrder.count).to eq(2)
      expect(WorkOrder.all.map(&:ref)).to contain_exactly('06183523', '01572924')
    end
  end
end
