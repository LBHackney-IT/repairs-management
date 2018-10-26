require 'rails_helper'

describe Graph::Note, :db_connection do
  it 'converts note_id to integer on create' do
    Graph::Note.create!(note_id: '1', source: 'test', logged_at: Time.current, work_order_reference: '0' * 8)

    expect(Graph::Note.first.id).to eq 1
  end
end
