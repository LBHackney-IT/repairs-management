class DeleteOldNotesJob < ApplicationJob
  queue_as :default

  NUMBER_TO_DELETE = 20_000

  def perform(earliest)
    Graph::Note.query_as(:n)
               .where("n.logged_at < #{earliest.to_i}")
               .with(:n).limit(NUMBER_TO_DELETE)
               .detach_delete(:n)
               .to_a
  end
end
