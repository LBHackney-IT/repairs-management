class WorkOrderImporterJob < ApplicationJob
  queue_as :default

  def perform(s3_object_name)
    data_stream = S3Client.new.s3_object_stream(s3_object_name)
    importer = GraphModelImporter.new(GraphModelImporter::WORK_ORDERS_IMPORT)

    CsvReader.new('work order').read_csv(data_stream) do |row|
      work_order_ref = row['wo_ref']
      property_ref = row['prop_ref']
      created = row['created']
      text = row['rq_problem']

      raise "missing data in: #{row}" unless [work_order_ref, property_ref, created].select(&:blank?).empty?
      raise "missing text in: #{row}" if text.nil?

      numbers = WorkOrderReferenceFinder.new(work_order_ref).find(text)

      Rails.logger.info("Importing work order: #{work_order_ref} from #{s3_object_name}")
      Neo4j::ActiveBase.run_transaction do
        importer.import_work_order(work_order_ref: work_order_ref,
                                   property_ref: property_ref,
                                   created: created,
                                   target_numbers: numbers)
        Graph::LastFromFeed.update_last_work_order!(work_order_ref)
      end
    end
  end
end
