class NotesFeedJob < ApplicationJob
  queue_as :feed

  ENQUEUE_LIMIT = 50

  def perform(enqueues, max_enqueues)
    notes = Hackney::Note.feed(Graph::Note.last_note_id)

    notes.each do |hackney_note|
      RelatedWorkOrderJob.perform_later(hackney_note.note_id,
                                        hackney_note.logged_at.iso8601,
                                        hackney_note.work_order_reference,
                                        extract_references(hackney_note))
    end

    if enqueues < max_enqueues && notes.size >= ENQUEUE_LIMIT
      NotesFeedJob.perform_later(enqueues + 1, max_enqueues)
    end
  end

  private

  # Scan the note for possible work order numbers in this job because we don't
  # want to store the text in redis - it may have private information
  def extract_references(hackney_note)
    WorkOrderReferenceFinder
      .new(hackney_note.work_order_reference)
      .find(hackney_note.text)
  end
end
