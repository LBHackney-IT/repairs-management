# This file is used by Heroku Scheduler

namespace :hackney do
  desc "Update work orders in the graph DB"
  task :update_graph_work_orders, [:executions, :wait_seconds] => [:environment] do |_t, args|
    wait = args[:wait_seconds]&.to_i || 0
    WorkOrderFeedJob.set(wait: wait.seconds).perform_later(1, args[:executions].to_i)
  end

  desc "Update notes in the graph DB"
  task :update_graph_notes, [:enqueues, :wait_seconds] => [:environment] do |_t, args|
    wait = args[:wait_seconds]&.to_i || 0
    NotesFeedJob.set(wait: wait.seconds).perform_later(1, args[:enqueues].to_i)
  end

  desc "add 'extra' to old citations"
  task :add_extra, [:times] => [:environment] do |_t, args|
    times = args[:times].to_i
    AddExtraJob.perform_later(times)
  end
end
