require 'rails_helper'

describe Graph::Note, 'model', :db_connection do
  let(:work_order) { Graph::WorkOrder.create(reference: '1') }
  let(:note) { Graph::Note.create(note_id: 'a') }

  before do
    work_order.notes << note
    work_order.reload
    note.reload
  end

  it 'has one work order' do
    expect(note.work_order).to eq work_order
  end

  it 'belongs to a work order' do
    expect(work_order.notes.all).to eq [note]
  end
end
