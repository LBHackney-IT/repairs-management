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

    Graph::Citation # Need this here because rails doesn't seem to autoload it for some reason
    cypher = "MATCH ()-[r:`GRAPH::CITATION`]-() WHERE NOT EXISTS(r.extra) RETURN r LIMIT 1"

    args[:times].to_i.times do |i|
      res = Neo4j::ActiveBase.current_session.query(cypher)

      citation = res.structs.first&.r

      if citation
        from = citation.from_node
        to = citation.to_node

        extra = from.related.include?(to)
        citation.extra = extra
        citation.save!

        puts "#{i}: #{from.reference}-[#{extra}]-#{to.reference}"
      else
        puts "#{i}: No citations without extra"
        break
      end
    end
  end
end
