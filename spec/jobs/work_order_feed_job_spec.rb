require 'rails_helper'

RSpec.describe WorkOrderFeedJob, :db_connection, type: :job do
  include ActiveJob::TestHelper

  let(:fifty_work_orders) { (1..50).map { build :work_order } }
  let(:ten_work_orders) { (1..10).map { build :work_order } }

  it 'imports a work order' do
    existing = Graph::WorkOrder.create! reference: '00000001'
    expect(Hackney::WorkOrder).to receive(:feed) do
      [
        build(:work_order, reference: '00000002',
                           problem_description: '-> 00000001')
      ]
    end

    WorkOrderFeedJob.new.perform(1, 1)

    imported =  Graph::WorkOrder.find('00000002')
    expect(imported.related).to eq [existing]
  end

  it 'retries if there are 50 work orders and we have not enqueues too many times' do
    allow(Hackney::WorkOrder).to receive(:feed).with('00000000') { fifty_work_orders }
    allow(Hackney::WorkOrder).to receive(:feed).with(fifty_work_orders.last.reference) { ten_work_orders }

    WorkOrderFeedJob.new.perform(1, 2)

    expect(Graph::WorkOrder.count).to eq 60
  end

  it 'does not retry if there are 50 work orders and we have enqueues the max number of times' do
    allow(Hackney::WorkOrder).to receive(:feed).with('00000000') { fifty_work_orders }
    allow(Hackney::WorkOrder).to receive(:feed).with(fifty_work_orders.last.reference) { ten_work_orders }

    WorkOrderFeedJob.new.perform(1, 1)

    expect(Graph::WorkOrder.count).to eq 50
  end
end
