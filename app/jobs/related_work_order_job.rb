class RelatedWorkOrderJob < ApplicationJob
  queue_as :default

  def perform(note_id, logged_at, work_order_reference, target_numbers)
    GraphModelImporter
      .new(self.class.name)
      .import_note(note_id, logged_at, work_order_reference, target_numbers)
  end
end
