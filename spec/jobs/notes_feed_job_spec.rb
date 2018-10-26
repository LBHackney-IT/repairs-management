require 'rails_helper'

RSpec.describe NotesFeedJob, :db_connection, type: :job do
  include ActiveJob::TestHelper

  let(:today) { DateTime.current.beginning_of_day }

  let(:hackney_note) do
    build :hackney_note, text: 'related to 00000001', logged_at: today, work_order_reference: '00000002'
  end

  it 'enqueues related work order jobs' do
    expect(Hackney::Note).to receive(:feed) { [hackney_note] }

    expect {
      NotesFeedJob.new.perform(1, 1)
    }.to have_enqueued_job(RelatedWorkOrderJob).with(hackney_note.note_id, today, '00000002', ['00000001'])
  end

  it 'enqueues a job with no numbers when there are no numbers in the text' do
    hackney_note.text = 'some sensitive text'
    expect(Hackney::Note).to receive(:feed) { [hackney_note] }

    NotesFeedJob.new.perform(1, 1)

    expect(RelatedWorkOrderJob).to have_been_enqueued.exactly(:once)
    expect(RelatedWorkOrderJob).to have_been_enqueued.with(hackney_note.note_id, today, '00000002', [])
  end


  it 'enqueues a job with all numbers extracted from the notes text' do
    hackney_note.text = '00000001, 00000002, 00000003, 000000004, 0005'
    expect(Hackney::Note).to receive(:feed) { [hackney_note] }

    NotesFeedJob.new.perform(1, 1)

    expect(RelatedWorkOrderJob).to have_been_enqueued.exactly(:once)
    expect(RelatedWorkOrderJob).to have_been_enqueued.with(hackney_note.note_id, today, '00000002', ['00000001', '00000003'])
  end

  it 'enqueues a job for every note in the feed' do
    notes = (1..3).map { |x| build :hackney_note, text: ('related to %08d' % x) }
    expect(Hackney::Note).to receive(:feed) { notes }

    NotesFeedJob.new.perform(1, 1)

    expect(RelatedWorkOrderJob).to have_been_enqueued.exactly(:thrice)
  end

  it "asks for notes greater than 1 by default" do
    expect(Hackney::Note).to receive(:feed).with(1) { [] }

    NotesFeedJob.new.perform(1, 1)
  end

  it "asks for notes that we don't know about" do
    Graph::Note.create!(note_id: 2, logged_at: Time.current, source: 'test', work_order_reference: '01234567')

    expect(Hackney::Note).to receive(:feed).with(2) { [] }

    NotesFeedJob.new.perform(1, 1)
  end

  it 'enqueues another job if there are 50 results' do
    expect(Hackney::Note).to receive(:feed) { (0..49).map { build :hackney_note } }

    expect {
      NotesFeedJob.new.perform(1, 2)
    }.to have_enqueued_job(NotesFeedJob).with(2, 2)
  end

  it "doesn't enqueues another job if there are < 50 results" do
    expect(Hackney::Note).to receive(:feed) { [hackney_note] }

    expect {
      NotesFeedJob.new.perform(1, 2)
    }.to_not have_enqueued_job(NotesFeedJob)
  end

  it "doesn't enqueue if we've enqueued it too many times" do
    expect(Hackney::Note).to receive(:feed) { (0..49).map { build :hackney_note } }

    expect {
      NotesFeedJob.new.perform(5, 5)
    }.to_not have_enqueued_job(NotesFeedJob)
  end

end
