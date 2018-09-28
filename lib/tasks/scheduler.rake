# This file is used by Heroku Scheduler

namespace :hackney do
  desc "Update graph DB"
  task :update_graph_db => :environment do
    NotesFeedJob.perform_later(1, Rails.configuration.notes_feed_max_enqueues)
  end

  desc "preload graph work orders"
  task :preload_graph_orders => :environment do
    importer = GraphModelImporter.new(GraphModelImporter::WORK_ORDERS_IMPORT)

    CsvReader.new('work order').read_csv do |row|
      work_order_ref = row['wo_ref']
      property_ref = row['prop_ref']
      created = row['created']
      text = row['rq_problem']

      raise "missing data in: #{row}" unless [work_order_ref, property_ref, created, text].select(&:blank?).empty?

      numbers = WorkOrderReferenceFinder.new(work_order_ref).find(text)

      importer.import_work_order(work_order_ref, property_ref, created, numbers)
    end
  end

  desc "preload graph notes"
  task :preload_graph_notes => :environment do
    importer = GraphModelImporter.new(GraphModelImporter::NOTES_IMPORT)

    CsvReader.new('note').read_csv do |row|
      work_order_ref = row['WorkOrderReference']
      text = row['Text']
      note_id = row['NoteID']
      logged_at = row['LoggedAt']

      raise "missing data in: #{row}" unless [note_id, logged_at, work_order_ref, text].select(&:blank?).empty?

      numbers = WorkOrderReferenceFinder.new(work_order_ref).find(text)
      numbers = numbers.select {|n| n < '02000000' } # we know for the import that all work orders are less than this

      importer.import_note(note_id, logged_at, work_order_ref, numbers)
    end
  end
end
