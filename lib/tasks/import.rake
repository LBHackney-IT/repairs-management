require 'csv'

namespace :hackney do

  desc "preload graph work orders"
  task :preload_graph_orders, [:s3_object_name] => [:environment] do |_t, args|

    Rails.logger.level = Logger::INFO

    data_stream = S3Client.new.s3_object_stream(args[:s3_object_name])
    importer = GraphModelImporter.new(GraphModelImporter::WORK_ORDERS_IMPORT)

    CsvReader.new('work order').read_csv(data_stream) do |row|
      work_order_ref = row['wo_ref']
      property_ref = row['prop_ref']
      created = row['created']
      text = row['rq_problem']

      raise "missing data in: #{row}" unless [work_order_ref, property_ref, created].select(&:blank?).empty?
      raise "missing text in: #{row}" if text.nil?

      numbers = WorkOrderReferenceFinder.new(work_order_ref).find(text)

      importer.import_work_order(work_order_ref, property_ref, created, numbers)
    end
  end

  desc "preload graph notes"
  task :preload_graph_notes, [:s3_object_name] => [:environment] do |_t, args|

    Rails.logger.level = Logger::INFO

    data_stream = S3Client.new.s3_object_stream(args[:s3_object_name])
    importer = GraphModelImporter.new(GraphModelImporter::NOTES_IMPORT)

    CsvReader.new('note').read_csv(data_stream) do |row|
      work_order_ref = row['WorkOrderReference']
      text = row['Text']
      note_id = row['NoteId']
      logged_at = row['LoggedAt']

      raise "missing data in: #{row}" unless [note_id, logged_at, work_order_ref].select(&:blank?).empty?
      raise "missing text in: #{row}" if text.nil?

      numbers = WorkOrderReferenceFinder.new(work_order_ref).find(text)
      numbers = numbers.select {|n| n < '02000000' } # we know for the import that all work orders are less than this

      importer.import_note(note_id, logged_at, work_order_ref, numbers)
    end
  end

  desc "preprocess a csv file"
  task :preprocess_csv, [:file, :work_order_ref_col, :text_column, :batch_size] => [:environment] do |_t, args|

    count = 0
    output = nil
    batch_size = args[:batch_size].to_i

    CSV.foreach(args[:file], headers: true) do |row|
      if count % batch_size == 0
        output.close if output
        output = CSV.open(("%s-%04d" % [args[:file], count / batch_size]), "wb", write_headers: true, headers: row.headers)
        print('*')
      end

      work_order_ref = row[args[:work_order_ref_col]]
      text = row[args[:text_column]]
      numbers = WorkOrderReferenceFinder.new(work_order_ref).find(text)
      row[args[:text_column]] = numbers.join(' ')
      output << row

      count += 1
      print('.')
    end

    output.close if output
    puts "!"
  end

end
