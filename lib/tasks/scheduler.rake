# This file is used by Heroku Scheduler

namespace :hackney do
  desc "Update work orders in the graph DB"
  task :update_graph_work_orders, [:executions, :wait_seconds] => [:environment] do |_t, args|
    waits = args[:wait_seconds].split('-').map(&:to_i)
    waits.each do |wait|
      WorkOrderFeedJob.set(wait: wait.seconds).perform_later(1, args[:executions].to_i)
    end
  end

  desc "Update notes in the graph DB"
  task :update_graph_notes, [:enqueues, :limit, :wait_seconds] => [:environment] do |_t, args|
    waits = args[:wait_seconds].split('-').map(&:to_i)
    waits.each do |wait|
      NotesFeedJob.set(wait: wait.seconds).perform_later(1, args[:enqueues].to_i)
    end
  end

  desc "Delete notes older than X years"
  task :delete_old_notes, [:years] => :environment do |_t, args|
    years = args[:years].to_i

    DeleteOldNotesJob.perform_later(years.years.ago.iso8601)
  end
end
