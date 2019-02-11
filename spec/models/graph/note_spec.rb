require 'rails_helper'

describe Graph::Note, :db_connection do
  it 'converts note_id to integer on create' do
    Graph::Note.create!(note_id: '1', source: 'test', logged_at: Time.current, work_order_reference: '0' * 8)

    expect(Graph::Note.first.id).to eq 1
  end

  it 'gets the last note id' do
    Graph::Note.create!(note_id: 8_999_999, source: 'test', logged_at: Time.current, work_order_reference: '0' * 8)
    Graph::Note.create!(note_id: 9_000_001, source: 'test', logged_at: Time.current, work_order_reference: '0' * 8)

    expect(Graph::Note.last_note_id).to eq 9_000_001
  end

  it 'returns the last note id when there are less than 9 million records' do
    Graph::Note.create!(note_id: 8_999_999, source: 'test', logged_at: Time.current, work_order_reference: '0' * 8)

    expect(Graph::Note.last_note_id).to eq 8_999_999
  end
end
