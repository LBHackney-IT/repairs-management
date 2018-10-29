require 'rails_helper'

describe Graph::Citation, 'cite_by_note!', :db_connection do
  let!(:work_order_a) { create(:graph_work_order, reference: 'a') }
  let!(:work_order_b) { create(:graph_work_order, reference: 'b') }
  let!(:work_order_c) { create(:graph_work_order, reference: 'c') }

  it 'creates a citation between two work orders' do
    Graph::Citation.cite_by_note!(from: work_order_a, to: work_order_b,
                                  note_id: 1, source: 'test')

    citations = work_order_a.citations_for(work_order_b)
    expect(citations.size).to eq 1
    expect(citations.first.extra).to eq false
    expect(citations.first.note_id).to eq 1
    expect(citations.first.source).to eq 'test'
  end

  it 'marks the second citation as extra' do
    Graph::Citation.cite_by_note!(from: work_order_a, to: work_order_b,
                                  note_id: 1, source: 'test')

    Graph::Citation.cite_by_note!(from: work_order_b, to: work_order_c,
                                  note_id: 2, source: 'test')

    Graph::Citation.cite_by_note!(from: work_order_a, to: work_order_c,
                                  note_id: 3, source: 'test')

    citations = work_order_a.citations_for(work_order_c)
    expect(citations.size).to eq 1
    expect(citations.first.extra).to eq true
  end

  it 'ignores self citations' do
    Graph::Citation.cite_by_note!(from: work_order_a, to: work_order_a,
                                  note_id: 1, source: 'test')

    citations = work_order_a.citations_for(work_order_a)
    expect(citations.size).to eq 0
  end
end

describe Graph::Citation, 'cite_by_work_order!', :db_connection do
  let!(:work_order_a) { create(:graph_work_order, reference: 'a') }
  let!(:work_order_b) { create(:graph_work_order, reference: 'b') }
  let!(:work_order_c) { create(:graph_work_order, reference: 'c') }

  it 'creates a citation between two work orders' do
    Graph::Citation.cite_by_work_order!(from: work_order_a, to: work_order_b,
                                        source: 'test')

    citations = work_order_a.citations_for(work_order_b)
    expect(citations.size).to eq 1
    expect(citations.first.extra).to eq false
    expect(citations.first.work_order_reference).to eq 'a'
    expect(citations.first.source).to eq 'test'
  end

  it 'marks the second citation as extra' do
    Graph::Citation.cite_by_work_order!(from: work_order_a, to: work_order_b,
                                        source: 'test')
    Graph::Citation.cite_by_work_order!(from: work_order_b, to: work_order_c,
                                        source: 'test')
    Graph::Citation.cite_by_work_order!(from: work_order_a, to: work_order_c,
                                        source: 'test')

    citations = work_order_a.citations_for(work_order_c)
    expect(citations.size).to eq 1
    expect(citations.first.extra).to eq true
  end

  it 'ignores self citations' do
    Graph::Citation.cite_by_work_order!(from: work_order_a, to: work_order_a,
                                        source: 'test')

    citations = work_order_a.citations_for(work_order_a)
    expect(citations.size).to eq 0
  end

end
