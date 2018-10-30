require 'rails_helper'

RSpec.describe DeleteOldNotesJob, :db_connection, type: :job do
  let(:ten_years_ago) { 10.years.ago }

  it 'deletes notes logged at over 10 years ago' do
    create(:graph_note, note_id: 1, logged_at: ten_years_ago - 1.year)
    create(:graph_note, note_id: 2, logged_at: ten_years_ago - 1.second)
    create(:graph_note, note_id: 3, logged_at: ten_years_ago)
    create(:graph_note, note_id: 4, logged_at: ten_years_ago + 1.year)

    DeleteOldNotesJob.perform_now(ten_years_ago.iso8601)

    expect(Graph::Note.all.map(&:note_id)).to contain_exactly(3, 4)
  end
end
