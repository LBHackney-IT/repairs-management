class RelatedWorkOrderJob < ApplicationJob
  queue_as :feed

  def perform(note_id, logged_at, work_order_reference, target_numbers)
    GraphModelImporter
      .new(self.class.name)
      .import_note(note_id: note_id,
                   logged_at: logged_at,
                   work_order_reference: work_order_reference,
                   target_numbers: target_numbers)
  end
end
