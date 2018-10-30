require 'rails_helper'

RSpec.describe WorkOrderFeedJob, :db_connection, type: :job do
  include ActiveJob::TestHelper

  let(:fifty_work_orders) { (1..50).map { build :work_order } }
  let(:ten_work_orders) { (1..10).map { build :work_order } }

  it 'imports a work order' do
    existing = create(:graph_work_order, reference: '00000001', source: WorkOrderFeedJob.source_name)
    expect(Hackney::WorkOrder).to receive(:feed).with('00000001') do
      [
        build(:work_order, reference: '00000002',
                           problem_description: '-> 00000001')
      ]
    end

    WorkOrderFeedJob.perform_now(1, 1)

    imported =  Graph::WorkOrder.find('00000002')
    expect(imported.related).to eq [existing]
    expect(Graph::LastFromFeed.last_work_order.last_id).to eq '00000002'
  end

  it 'retries if there are 50 work orders and we have not enqueues too many times' do
    allow(Hackney::WorkOrder).to receive(:feed).with('00000000') { fifty_work_orders }
    allow(Hackney::WorkOrder).to receive(:feed).with(fifty_work_orders.last.reference) { ten_work_orders }

    WorkOrderFeedJob.perform_now(1, 2)

    expect(Graph::WorkOrder.count).to eq 60
    expect(Graph::LastFromFeed.last_work_order.last_id).to eq ten_work_orders.last.reference
  end

  it 'does not retry if there are 50 work orders and we have enqueues the max number of times' do
    allow(Hackney::WorkOrder).to receive(:feed).with('00000000') { fifty_work_orders }
    allow(Hackney::WorkOrder).to receive(:feed).with(fifty_work_orders.last.reference) { ten_work_orders }

    WorkOrderFeedJob.perform_now(1, 1)

    expect(Graph::WorkOrder.count).to eq 50
    expect(Graph::LastFromFeed.last_work_order.last_id).to eq fifty_work_orders.last.reference
  end
end
