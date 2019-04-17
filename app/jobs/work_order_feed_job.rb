# WorkOrders must be imported in sequence, this is because work orders can
# relate to other work orders in the past. If we were to have a situation where
# the import fails for 1 WorkOrder we would want all subsequent ones to stop.
class WorkOrderFeedJob < ApplicationJob
  queue_as :feed

  EXECUTION_LIMIT = 50
  FIRST_REFERENCE = "00000000".freeze

  def perform(execution, max_executions)
    last = Graph::LastFromFeed.profile.last_work_order.last_id || FIRST_REFERENCE
    work_orders = Hackney::WorkOrder.feed(last)

    importer = GraphModelImporter.new(self.class.source_name)

    work_orders.each do |work_order|
      numbers = extract_references(work_order)

      Neo4j::ActiveBase.run_transaction do
        importer.import_work_order(work_order_ref: work_order.reference,
                                   property_ref: work_order.prop_ref,
                                   created: work_order.created,
                                   target_numbers: numbers)

        Graph::LastFromFeed.profile.update_last_work_order!(work_order.reference)
      end
    end

    if execution < max_executions && work_orders.size >= EXECUTION_LIMIT
      perform(execution + 1, max_executions)
    end

  rescue StandardError => e
    Appsignal.set_error(e)
  end

  private

  def self.source_name
    self.name
  end

  def extract_references(work_order)
    WorkOrderReferenceFinder
      .new(work_order.reference)
      .find(work_order.problem_description)
      .select { |n| n < work_order.reference } # work orders can only refer to previous work orders
  end

end
