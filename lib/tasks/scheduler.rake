# This file is used by Heroku Scheduler

namespace :hackney do
  desc "Update graph DB"
  task :update_graph_db => :environment do
    NotesFeedJob.perform_later(1, Rails.configuration.notes_feed_max_enqueues)
  end

  desc "preload graph work orders"
  task :preload_graph_orders => :environment do
    importer = GraphModelImporter.new('work-orders-import')

    CsvReader.new('work order').read_csv do |row|
      work_order_ref = row['wo_ref']
      property_ref = row['prop_ref']
      created = row['created']
      text = row['rq_problem']
      numbers = WorkOrderReferenceFinder.new(work_order_ref).find(text)

      importer.import_work_order(work_order_ref, property_ref, created, numbers)
    end
  end

  desc "preload graph notes"
  task :preload_graph_notes => :environment do
    importer = GraphModelImporter.new('notes-import')

    CsvReader.new('note').read_csv do |row|
      work_order_ref = row['WorkOrderReference']
      text = row['Text']
      note_id = row['NoteId']
      logged_at = row['LoggedAt']
      numbers = WorkOrderReferenceFinder.new(work_order_ref).find(text)

      importer.import_note(note_id, work_order_ref, logged_at, numbers)
    end
  end
end
