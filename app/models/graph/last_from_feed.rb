# Track the last imported work order from the feed or import process
#
# The notes import can create work orders if necessary and could run ahead of
# the work orders by 50 if anything goes wrong with the work orders feed
class Graph::LastFromFeed
  include Neo4j::ActiveNode
  include Neo4j::Timestamps::Updated

  id_property :feed_type

  property :last_id, type: String

  def self.last_work_order
    last = Graph::LastFromFeed.find_by(feed_type: Graph::WorkOrder.name)
    last ||= Graph::LastFromFeed.create!(feed_type: Graph::WorkOrder.name,
                                         last_id: find_last_work_order)
    last
  end

  def self.update_last_work_order!(work_order_ref)
    last_work_order.update!(last_id: work_order_ref)
  end

  def self.find_last_work_order
    ordered_sources = [GraphModelImporter::WORK_ORDERS_IMPORT, WorkOrderFeedJob.source_name]
    Graph::WorkOrder.where(source: ordered_sources, reference: /^\d{8}$/).last&.reference
  end
end
