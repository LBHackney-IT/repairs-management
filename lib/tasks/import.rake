require 'csv'

namespace :hackney do

  desc "preload graph work orders"
  task :preload_graph_orders, [:s3_object_name] => [:environment] do |_t, args|

    Rails.logger.level = Logger::INFO

    WorkOrderImporterJob.new.perform(args[:s3_object_name])
  end

  desc "preload graph notes"
  task :preload_graph_notes, [:s3_object_name] => [:environment] do |_t, args|

    Rails.logger.level = Logger::INFO

    NoteImporterJob.new.perform(args[:s3_object_name])
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
      text = row[args[:text_column]] || ""
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
