class NotesFeedJob < ApplicationJob
  queue_as :feed

  def perform(enqueues, max_enqueues, enqueue_limit)
    notes = Hackney::Note.feed(last_note_id, limit: enqueue_limit)

    notes.each do |hackney_note|
      RelatedWorkOrderJob.perform_later(hackney_note.note_id,
                                        hackney_note.logged_at.iso8601,
                                        hackney_note.work_order_reference,
                                        extract_references(hackney_note))
      Graph::LastFromFeed.update_last_note!(hackney_note.note_id)
    end

    if enqueues < max_enqueues && notes.size >= enqueue_limit
      NotesFeedJob.perform_later(enqueues + 1, max_enqueues, enqueue_limit)
    end

  rescue StandardError => e
    Appsignal.set_error(e)
  end

  private

  def last_note_id
    Graph::LastFromFeed.last_note.last_id.to_i
  end

  # Scan the note for possible work order numbers in this job because we don't
  # want to store the text in redis - it may have private information
  def extract_references(hackney_note)
    WorkOrderReferenceFinder
      .new(hackney_note.work_order_reference)
      .find(hackney_note.text || "")
  end
end
