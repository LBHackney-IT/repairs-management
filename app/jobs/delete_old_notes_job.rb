class DeleteOldNotesJob < ApplicationJob
  queue_as :default

  NUMBER_TO_DELETE = 10_000

  def perform(earliest)
    date = DateTime.parse(earliest).to_i
    Graph::Note.query_as(:n)
               .where("n.logged_at < #{date}")
               .with(:n).limit(NUMBER_TO_DELETE)
               .detach_delete(:n)
               .to_a
  end
end
