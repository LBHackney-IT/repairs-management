class NoteImporterJob < ApplicationJob
  queue_as :default

  def perform(s3_object_name)
    data_stream = S3Client.new.s3_object_stream(s3_object_name)
    importer = GraphModelImporter.new(GraphModelImporter::NOTES_IMPORT)

    # We know for the import that all work orders are <= than this because we
    # import work orders first
    last_work_order = Graph::WorkOrder.where(reference: /^\d+$/).last&.reference || "00000000"

    CsvReader.new('note').read_csv(data_stream) do |row|
      work_order_ref = row['WorkOrderReference']
      text = row['Text']
      note_id = row['NoteId']
      logged_at = row['LoggedAt']

      raise "missing data in: #{row}" unless [note_id, logged_at, work_order_ref].select(&:blank?).empty?
      raise "missing text in: #{row}" if text.nil?

      numbers = WorkOrderReferenceFinder.new(work_order_ref).find(text)
      numbers = numbers.select { |n| n <= last_work_order }

      importer.import_note(note_id, logged_at, work_order_ref, numbers)
    end
  end
end
