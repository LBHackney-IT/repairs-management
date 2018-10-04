class NoteImporterJob < ApplicationJob
  queue_as :default

  def perform(s3_object_name)
    data_stream = S3Client.new.s3_object_stream(s3_object_name)
    importer = GraphModelImporter.new(GraphModelImporter::NOTES_IMPORT)

    CsvReader.new('note').read_csv(data_stream) do |row|
      work_order_ref = row['WorkOrderReference']
      text = row['Text']
      note_id = row['NoteId']
      logged_at = row['LoggedAt']

      raise "missing data in: #{row}" unless [note_id, logged_at, work_order_ref].select(&:blank?).empty?
      raise "missing text in: #{row}" if text.nil?

      numbers = WorkOrderReferenceFinder.new(work_order_ref).find(text)
      numbers = numbers.select { |n| n < '02000000' } # we know for the import that all work orders are less than this

      importer.import_note(note_id, logged_at, work_order_ref, numbers)
    end
  end
end
