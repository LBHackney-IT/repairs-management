require 'rails_helper'

describe Graph::WorkOrder, 'related', :db_connection do
  let!(:work_order_a) { create(:graph_work_order, reference: 'a') }
  let!(:work_order_b) { create(:graph_work_order, reference: 'b') }
  let!(:work_order_c) { create(:graph_work_order, reference: 'c') }
  let!(:work_order_d) { create(:graph_work_order, reference: 'd') }
  let!(:work_order_e) { create(:graph_work_order, reference: 'e') }
  let!(:work_order_f) { create(:graph_work_order, reference: 'f') }
  let!(:work_order_g) { create(:graph_work_order, reference: 'g') }
  let!(:work_order_h) { create(:graph_work_order, reference: 'h') }
  let!(:work_order_i) { create(:graph_work_order, reference: 'i') }
  let!(:work_order_j) { create(:graph_work_order, reference: 'j') }
  let!(:work_order_k) { create(:graph_work_order, reference: 'k') }
  let!(:work_order_l) { create(:graph_work_order, reference: 'l') }
  let!(:work_order_m) { create(:graph_work_order, reference: 'm') }

  it 'finds no related orders when there are no citations' do
    expect(work_order_a.related).to eq []
    expect(work_order_b.related).to eq []
    expect(work_order_c.related).to eq []
  end

  it 'finds related work orders in both directions' do
    Graph::Citation.cite_by_work_order!(from: work_order_b, to: work_order_a, source: 'test')

    expect(work_order_a.related).to contain_exactly(work_order_b)
    expect(work_order_b.related).to contain_exactly(work_order_a)
  end

  it 'finds transitively related work orders' do
    Graph::Citation.cite_by_note!(from: work_order_b, to: work_order_a, note_id: 1, source: 'test')
    Graph::Citation.cite_by_note!(from: work_order_c, to: work_order_b, note_id: 2, source: 'test')

    expect(work_order_a.related).to contain_exactly(work_order_b, work_order_c)
    expect(work_order_b.related).to contain_exactly(work_order_a, work_order_c)
    expect(work_order_c.related).to contain_exactly(work_order_a, work_order_b)
  end

  context 'complex data sets' do
    it 'works on long complex chains' do
      data = [
        [work_order_a, work_order_b],
        [work_order_b, work_order_c],
        [work_order_c, work_order_d],
        [work_order_c, work_order_a],
        [work_order_c, work_order_d],
        [work_order_c, work_order_e],
        [work_order_e, work_order_f],
        [work_order_e, work_order_a],
        [work_order_e, work_order_b],
        [work_order_e, work_order_c],
        [work_order_f, work_order_g],
        [work_order_g, work_order_h],
        [work_order_h, work_order_i],
        [work_order_i, work_order_j],
        [work_order_i, work_order_g]
      ]

      data.each_with_index do |(from, to)|
        Graph::Citation.cite_by_work_order!(from: from, to: to, source: 'test')
      end

      work_orders = data.flatten.uniq
      all_refs = work_orders.map(&:reference)

      work_orders.each do |wo|
        expected = all_refs - [wo.reference]
        related = wo.related.map(&:reference)
        expect(related).to contain_exactly(*expected)
      end
    end

    it 'work on a fully connected graph' do
      data = [
        work_order_a,
        work_order_b,
        work_order_c,
        work_order_d,
        work_order_e,
        work_order_f,
        work_order_g,
        work_order_h,
        work_order_i,
        work_order_j,
        work_order_k,
        work_order_l,
        work_order_m
      ]

      data.each do |wo_1|
        data.select{|x| x.reference > wo_1.reference}.each do |wo_2|
          Graph::Citation.cite_by_work_order!(from: wo_1, to: wo_2, source: 'test')
        end
      end

      all_refs = data.map(&:reference)
      data.each do |work_order|
        expected = all_refs - [work_order.reference]
        related = work_order.related.map(&:reference)
        expect(related).to contain_exactly(*expected)
      end
    end
  end
end
