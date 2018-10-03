require 'rails_helper'

describe Graph::WorkOrder, 'related', :db_connection do
  let!(:work_order_a) { Graph::WorkOrder.create(reference: 'a') }
  let!(:work_order_b) { Graph::WorkOrder.create(reference: 'b') }
  let!(:work_order_c) { Graph::WorkOrder.create(reference: 'c') }

  it 'finds no related orders when there are no citations' do
    expect(work_order_a.related).to eq []
    expect(work_order_b.related).to eq []
    expect(work_order_c.related).to eq []
  end

  it 'finds related work orders in both directions' do
    Graph::Citation.create(from_node: work_order_b, to_node: work_order_a, note_id: 1)

    expect(work_order_a.related).to contain_exactly(work_order_b)
    expect(work_order_b.related).to contain_exactly(work_order_a)
    expect(work_order_c.related).to eq []
  end

  it 'finds transitively related work orders' do
    Graph::Citation.create(from_node: work_order_b, to_node: work_order_a, note_id: 1)
    Graph::Citation.create(from_node: work_order_c, to_node: work_order_b, note_id: 2)

    expect(work_order_a.related).to contain_exactly(work_order_b, work_order_c)
    expect(work_order_b.related).to contain_exactly(work_order_a, work_order_c)
    expect(work_order_c.related).to contain_exactly(work_order_a, work_order_b)
  end

  it 'removes duplicates' do
    Graph::Citation.create(from_node: work_order_b, to_node: work_order_a, note_id: 1)
    Graph::Citation.create(from_node: work_order_b, to_node: work_order_a, note_id: 2)

    expect(work_order_a.related).to eq [work_order_b]
  end
end
