class NotesFeedJob < ApplicationJob
  queue_as :feed

  # FIXME: NotesFeedJob and RelatedWorkOrderJob must be performed in order.
  #
  # If NotesFeedJob is performed twice before RelatedWorkOrderJob, then the
  # RelatedWorkOrderJob jobs will be duplicated.
  def perform(enqueues, max_enqueues, enqueue_limit)
    notes = Hackney::Note.feed(Graph::Note.last_note_id, limit: enqueue_limit)

    notes.each do |hackney_note|
      RelatedWorkOrderJob.perform_later(hackney_note.note_id,
                                        hackney_note.logged_at.iso8601,
                                        hackney_note.work_order_reference,
                                        extract_references(hackney_note))
    end

    if enqueues < max_enqueues && notes.size >= enqueue_limit
      NotesFeedJob.perform_later(enqueues + 1, max_enqueues, enqueue_limit)
    end

  rescue StandardError => e
    Appsignal.set_error(e)
  end

  private

  # Scan the note for possible work order numbers in this job because we don't
  # want to store the text in redis - it may have private information
  def extract_references(hackney_note)
    WorkOrderReferenceFinder
      .new(hackney_note.work_order_reference)
      .find(hackney_note.text || "")
  end
end
