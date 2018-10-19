# This file is used by Heroku Scheduler

namespace :hackney do
  desc "Update work orders in the graph DB"
  task :update_graph_work_orders, [:enqueues] => [:environment] do |_t, args|
    WorkOrderFeedJob.perform_later(1, args[:enqueues].to_i)
  end

  desc "Update notes in the graph DB"
  task :update_graph_notes, [:enqueues] => [:environment] do |_t, args|
    NotesFeedJob.perform_later(1, args[:enqueues].to_i)
  end
end
