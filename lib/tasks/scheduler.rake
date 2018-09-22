# This file is used by Heroku Scheduler

namespace :hackney do
  desc "Import work orders"
  task :import_work_orders => :environment do
    WorkOrdersImporter.new.import
  end

  desc "Update graph DB"
  task :update_graph_db => :environment do
    NotesFeedJob.perform_later(1, Rails.configuration.notes_feed_max_enqueues)
  end
end
