# This file is used by Heroku Scheduler

namespace :hackney do
  desc "Update graph DB"
  task :update_graph_db => :environment do
    NotesFeedJob.perform_later(1, Rails.configuration.notes_feed_max_enqueues)
  end

  desc "preload graph work orders"
  task :preload_graph_orders => :environment do
    WorkOrdersImporter.new.import_work_orders
  end

  desc "preload graph notes"
  task :preload_graph_notes => :environment do
    WorkOrdersImporter.new.import_notes
  end
end
