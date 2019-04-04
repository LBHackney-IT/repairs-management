require 'rails_helper'

RSpec.describe NotesFeedJob, :db_connection, type: :job do
  include ActiveJob::TestHelper

  let(:today) { DateTime.current.beginning_of_day }

  let(:hackney_note) do
    build :hackney_note, text: 'related to 00000001', logged_at: today, work_order_reference: '00000002'
  end

  let (:empty_hackney_note) do
    build :hackney_note, text: nil, logged_at: today, work_order_reference: '00000003'
  end

  it 'enqueues related work order jobs' do
    expect(Hackney::Note).to receive(:feed) { [hackney_note] }

    expect {
      NotesFeedJob.perform_now(1, 1, 50)
    }.to have_enqueued_job(RelatedWorkOrderJob).with(hackney_note.note_id, today, '00000002', ['00000001'])
  end

  it 'enqueues a job with no numbers when there are no numbers in the text' do
    hackney_note.text = 'some sensitive text'
    expect(Hackney::Note).to receive(:feed) { [hackney_note] }

    NotesFeedJob.perform_now(1, 1, 50)

    expect(RelatedWorkOrderJob).to have_been_enqueued.exactly(:once)
    expect(RelatedWorkOrderJob).to have_been_enqueued.with(hackney_note.note_id, today, '00000002', [])
  end


  it 'enqueues a job with all numbers extracted from the notes text' do
    hackney_note.text = '00000001, 00000002, 00000003, 000000004, 0005'
    expect(Hackney::Note).to receive(:feed) { [hackney_note] }

    NotesFeedJob.perform_now(1, 1, 50)

    expect(RelatedWorkOrderJob).to have_been_enqueued.exactly(:once)
    expect(RelatedWorkOrderJob).to have_been_enqueued.with(hackney_note.note_id, today, '00000002', ['00000001', '00000003'])
  end

  it 'enqueues a job for every note in the feed' do
    notes = (1..3).map { |x| build :hackney_note, text: ('related to %08d' % x) }
    expect(Hackney::Note).to receive(:feed) { notes }

    NotesFeedJob.perform_now(1, 1, 50)

    expect(RelatedWorkOrderJob).to have_been_enqueued.exactly(:thrice)
  end

  it "asks for notes greater than 1 by default" do
    expect(Hackney::Note).to receive(:feed).with(1, limit: 50) { [] }

    NotesFeedJob.perform_now(1, 1, 50)
  end

  it 'saves the last note' do
    notes = (1..3).map { build :hackney_note }
    expect(Hackney::Note).to receive(:feed).with(1, limit: 50) { notes }

    NotesFeedJob.perform_now(1, 1, 50)

    expect(Graph::LastFromFeed.last_note.last_id.to_i).to eq notes.last.note_id
  end

  it "asks for notes that we don't know about" do
    notes = (1..3).map { build :hackney_note }

    Graph::LastFromFeed.update_last_note!(notes.first.note_id)

    expect(Hackney::Note).to receive(:feed).with(notes.first.note_id, limit: 50) { notes.last(2) }

    NotesFeedJob.perform_now(1, 1, 50)

    expect(Graph::LastFromFeed.last_note.last_id.to_i).to eq notes.last.note_id
  end

  it 'enqueues another job if there are 25 results' do
    expect(Hackney::Note).to receive(:feed) { 25.times.map { build :hackney_note } }

    expect {
      NotesFeedJob.perform_now(1, 2, 25)
    }.to have_enqueued_job(NotesFeedJob).with(2, 2, 25)
  end

  it "doesn't enqueues another job if there are < 25 results" do
    expect(Hackney::Note).to receive(:feed) { 24.times.map { build :hackney_note } }

    expect {
      NotesFeedJob.perform_now(1, 2, 25)
    }.to_not have_enqueued_job(NotesFeedJob)
  end

  it "doesn't enqueue if we've enqueued it too many times" do
    expect(Hackney::Note).to receive(:feed) { 25.times.map { build :hackney_note } }

    expect {
      NotesFeedJob.perform_now(5, 5, 25)
    }.to_not have_enqueued_job(NotesFeedJob)
  end

  it "doesn't blow up when a note's text is nil" do
    expect(Hackney::Note).to receive(:feed) { [empty_hackney_note] }

    expect {
      NotesFeedJob.perform_now(1, 1, 50)
    }.to_not raise_error
  end

  it "rescues errors and sends them to appsignal" do
    error = StandardError.new('BOOOM!')
    expect(Hackney::Note).to receive(:feed) { raise error }
    expect(Appsignal).to receive(:set_error).with(error)

    NotesFeedJob.perform_now(1, 1, 50)
  end
end
